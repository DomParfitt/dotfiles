from ansible.plugins.callback import CallbackBase
from datetime import datetime
import shutil

RESULT_SUCCESS = "SUCCESS"
RESULT_CHANGED = "CHANGED"
RESULT_FAILED = "FAILED"
RESULT_SKIPPED = "SKIPPED"


class CallbackModule(CallbackBase):

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'pretty_print'

    _current_role = None
    _current_task = None
    _parent_stack = []
    _processed_roles = []
    _start = datetime.now()

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.printer = Printer(self._display.display)

    def v2_playbook_on_task_start(self, task, is_conditional):
        if task._role is None:
            current_task = {
                "name": task.name,
                "start": datetime.now()
            }

            self._current_task = current_task
            return

        role_name = task._role._role_name

        if self._current_role is None:
            self._on_role_start(role_name)
        elif self._current_role['name'] != role_name:
            self._on_role_end()

            self._on_role_start(role_name)

        self._update_parent_stack(task)
        current_task = {
            "name": task.name,
            "start": datetime.now()
        }

        self._current_task = current_task

    def v2_runner_on_ok(self, result):
        if result.is_changed():
            self._current_role['result'] = RESULT_CHANGED
            self._on_task_end(RESULT_CHANGED, self._msg_from_result(result))
        else:
            self._on_task_end(RESULT_SUCCESS, self._msg_from_result(result))

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self._current_role['result'] = RESULT_FAILED
        self._on_task_end(RESULT_FAILED, self._msg_from_result(result, True))

    def v2_on_file_diff(self, result):
        self._on_task_end(RESULT_CHANGED, self._msg_from_result(result))

    def v2_runner_on_skipped(self, result):
        self._on_task_end(RESULT_SKIPPED, self._msg_from_result(result))

    def v2_playbook_on_stats(self, stats):
        self._on_role_end()

        self.printer.print_summary(self._start, self._processed_roles)

    def _on_role_start(self, role_name):
        self.printer.print_role_name(role_name)
        self._current_role = {
            "name": role_name,
            "tasks": [],
            "result": RESULT_SUCCESS,
            "start": datetime.now()
        }

    def _on_role_end(self):
        self._current_role['end'] = datetime.now()
        self._processed_roles.append(self._current_role)

    def _on_task_end(self, result, msg=None):
        if self._current_task is None:
            return

        self._current_task['result'] = result
        self._current_task['end'] = datetime.now()
        self._current_task['msg'] = msg
        if self._current_role is not None:
            self._current_role['tasks'].append(self._current_task)

        self.printer.print_task(
            self._current_task, indent_level=len(self._parent_stack) + 1)

    def _update_parent_stack(self, task):
        parentTask = task.get_first_parent_include()
        if parentTask is None:
            self._parent_stack = []
            return

        # Treat tasks with a parent that is not a task we've seen (i.e. those added with `import_tasks`)
        # as having no parent.
        if parentTask.name not in [task['name'] for task in self._current_role['tasks']]:
            return

        if len(self._parent_stack) == 0:
            self._parent_stack.append(parentTask)
            return

        currentParent = self._parent_stack.pop()
        sameParent = currentParent.name == parentTask.name
        self._parent_stack.append(currentParent)

        if not sameParent:
            self._parent_stack.append(parentTask)

    def _msg_from_result(self, result, force=False):
        if '_ansible_verbose_always' in result._result or force:
            return result._result['msg']

        return None


class Printer:

    def __init__(self, display):
        self.display = display

    def print_summary(self, start, processed_roles):
        self.display(f'\n')
        self.display('-' * self.output_width())
        self.display(self.bold('SUMMARY'))
        for role in processed_roles:
            self._print_role(role)

        self.display('-' * self.output_width())
        self._print_line(
            ["TOTAL", "", self._format_duration(start, datetime.now())],
        )
        self.display(f'\n')

    def print_role_name(self, role_name):
        self.display(f'\n')
        self.display(self.bold(role_name))

    def _print_role(self, role):
        name = role['name']
        result = role['result']
        start = role['start']
        end = role['end']

        self._print_line(
            [name,  result, self._format_duration(start, end)],
            color=self.result_color(result),
            indent_level=1
        )

    def print_task(self, task, indent_level=1):
        name = task['name']
        result = task['result']
        msg = task['msg']
        start = task['start']
        end = task['end']

        self._print_line(
            [name, result, self._format_duration(start, end)],
            color=self.result_color(result),
            indent_level=indent_level
        )

        self._print_msg(msg, indent_level, self.result_color(result))

    def _print_msg(self, msg, indent_level, color):
        if msg is None:
            return

        if isinstance(msg, list):
            for line in msg:
                self._print_line(
                    [self.italic("".join(line))],
                    color=color,
                    indent_level=indent_level + 1)
        else:
            self._print_line(
                [self.italic("".join(msg))],
                color=color,
                indent_level=indent_level + 1)

    def _print_line(self, items, color='white', indent_level=0):
        indent = indent_level * 2
        line = ""
        column_size = round(self.output_width() / len(items))
        for idx, item in enumerate(items):
            if idx == 0:
                spaces = indent * ' '
                line += f'{spaces}{item}{self.spacing(item, desired_spacing=column_size-indent)}'
            else:
                line += f'{item}{self.spacing(item, desired_spacing=column_size)}'

        self.display(line.rstrip(), color=color)

    def bold(self, string):
        return f'\033[1m{string}\033[0m'

    def italic(self, string):
        return f'\033[2m{string}\033[0m'

    def spacing(self, first_entry, desired_spacing=25):
        return ' ' * (desired_spacing - len(first_entry))

    def output_width(self):
        try:
            return shutil.get_terminal_size().columns
        except:
            return 100

    def result_color(self, result):
        if result == RESULT_SUCCESS:
            return 'green'
        elif result == RESULT_SKIPPED:
            return 'blue'
        elif result == RESULT_CHANGED:
            return 'yellow'
        elif result == RESULT_FAILED:
            return 'red'
        else:
            return 'white'

    def _format_duration(self, start, end):
        total_duration = (end - start)
        seconds = total_duration.total_seconds()
        if seconds >= 60:
            seconds_remaining = seconds % 60
            minutes = (seconds - seconds_remaining) / 60
            duration = "{0:.0f}m{1:.0f}s".format(minutes, seconds_remaining)
        elif seconds >= 1:
            duration = "{0:.2f}s".format(seconds)
        else:
            duration = "{0:.0f}ms".format(seconds * 1000)
        return duration
