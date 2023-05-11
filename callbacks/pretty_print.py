from ansible.plugins.callback import CallbackBase
from ansible.utils.color import stringc
from datetime import datetime
import shutil
from enum import Enum


class Result(Enum):
    FAILED = "FAILED"
    CHANGED = "CHANGED"
    SUCCESS = "SUCCESS"
    SKIPPED = "SKIPPED"
    NONE = ""

    def __str__(self) -> str:
        return self.value

    def __len__(self) -> int:
        return len(self.value)

    def color(self):
        if self == Result.SUCCESS:
            return 'green'
        elif self == Result.SKIPPED:
            return 'blue'
        elif self == Result.CHANGED:
            return 'yellow'
        elif self == Result.FAILED:
            return 'red'
        else:
            return 'bright gray'

    def flatten(results):
        for result in Result:
            if result in results:
                return result
        return Result.SKIPPED


class CallbackModule(CallbackBase):

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'pretty_print'

    _show_skipped = False

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
            role_name = "setup"
        else:
            role_name = task._role._role_name

        if self._current_role is None:
            self._on_role_start(role_name)
        elif self._current_role['name'] != role_name:
            self._on_role_end()

            self._on_role_start(role_name)

        self._update_parent_stack(task)

        self._current_task = {
            "name": task.name,
            "start": datetime.now()
        }

    def v2_playbook_on_stats(self, stats):
        self._on_role_end()
        self.printer.print_summary(self._start, self._processed_roles)

    def v2_runner_on_ok(self, result):
        if result.is_changed():
            res = Result.CHANGED
        else:
            res = Result.SUCCESS

        include = self._include_file_from_result(result)
        if include is not None:
            res = Result.NONE
            self._current_task['display_name'] = f"{self._current_task['name']} ({include})"

        self._on_task_end(res, self._msg_from_result(result))

    def v2_runner_on_skipped(self, result):
        self._on_task_end(Result.SKIPPED, self._msg_from_result(result))

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self._on_task_end(
            Result.FAILED, self._msg_from_result(result, force=True))

    def v2_on_file_diff(self, result):
        self._on_task_end(Result.CHANGED, self._msg_from_result(result))

    def v2_runner_item_on_ok(self, result):
        # import pprint
        # loop_var = result._result['ansible_loop_var']
        # self._display.display("Item OK")
        # self._display.display(pprint.pformat(result._result[loop_var]))
        # self._display.display(pprint.pformat(result._result))
        pass

    def v2_runner_item_on_failed(self, result):
        pass

    def v2_runner_item_on_skipped(self, result):
        pass

    def _on_role_start(self, role_name):
        self._current_role = {
            "name": role_name,
            "tasks": [],
            "result": Result.SUCCESS,
            "start": datetime.now()
        }

    def _on_role_end(self):
        self._current_role['end'] = datetime.now()
        self._current_role['result'] = Result.flatten(
            [task['result'] for task in self._current_role['tasks']])

        if len(self._current_role['tasks']) != 0:
            self._processed_roles.append(self._current_role)

    def _on_task_end(self, result, msg=None):
        if self._current_task is None:
            return

        if result == Result.SKIPPED and not self._show_skipped:
            return

        # If this is the first task we've completed for the current role then we need to print the
        # role name first
        if len(self._current_role['tasks']) == 0:
            self.printer.print_role_name(self._current_role['name'])

        self._current_task['result'] = result
        self._current_task['end'] = datetime.now()
        self._current_task['msg'] = msg
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
        if '_ansible_verbose_always' not in result._result and not force:
            return None

        if 'results' not in result._result:
            return result._result['msg']

        failed_results = [
            result for result in result._result['results'] if result['failed']]

        msgs = []
        for fail in failed_results:
            loop_var = fail['ansible_loop_var']
            if 'stderr_lines' in fail:
                msg = fail['stderr_lines'][0]
            else:
                msg = fail['msg']

            msgs.append({
                "item": fail[loop_var],
                "msg": msg
            })

        return msgs

    def _include_file_from_result(self, result):
        if 'results' not in result._result:
            return

        results = result._result['results']

        if len(results) == 0:
            return

        if 'include' not in results[0]:
            return

        include = results[0]['include']
        include = str.split(include, '/')
        include = include[len(include) - 1]
        include = str.split(include, '.')
        return include[0]


class Printer:

    def __init__(self, print):
        self.print = print

    def print_role_name(self, role_name):
        self._print_line()
        self._print_line(role_name, bold=True)

    def print_task(self, task, indent_level=1):
        if 'display_name' in task:
            name = task['display_name']
        else:
            name = task['name']

        result = task['result']

        if result == Result.NONE:
            duration = ''
        else:
            start = task['start']
            end = task['end']
            duration = Printer._format_duration(start, end)

        color = result.color()

        self._print_line(
            [name, result, duration],
            color=color,
            indent_level=indent_level
        )

        msg = task['msg']
        if msg is not None:
            self._print_msg(msg, indent_level, color)

    def print_summary(self, start, roles):
        self._print_line()
        self._print_linebreak()
        self._print_line(['SUMMARY'], bold=True)

        results = []
        for role in roles:
            results.append(role['result'])
            self._print_role_summary(role)

        result = Result.flatten(results)

        self._print_line()
        self._print_linebreak()
        self._print_line(
            [
                "OVERALL",
                {
                    "text": result,
                    "color": result.color()
                },
                Printer._format_duration(start, datetime.now())
            ],
            bold=True,
        )
        self._print_line()

    def _print_role_summary(self, role):
        name = role['name']
        result = role['result']
        start = role['start']
        end = role['end']

        duration = Printer._format_duration(start, end)

        self._print_line(
            [name,  result, duration],
            color=result.color(),
            indent_level=1
        )

    def _print_msg(self, msg, indent_level, color):

        def print_msg_line(string):
            self._print_line(
                "".join(string),
                color=color,
                italic=True,
                indent_level=indent_level + 1)

        if isinstance(msg, list):
            for line in msg:
                if isinstance(line, dict):
                    print_msg_line(f"- Item: {line['item']}")
                    print_msg_line(f"  Msg:  {line['msg']}")
                else:
                    print_msg_line(line)
        else:
            print_msg_line(msg)

    def _print_linebreak(self, char='='):
        self._print_line(char * Printer._output_width())

    def _print_line(self, items=[], color='bright gray', indent_level=0, bold=False, italic=False):

        def format_item(item, color):
            if bold:
                item = f'\033[1m{item}\033[0m'

            if italic:
                item = f'\033[2m{item}\033[0m'

            return f"{stringc(str(item), color)}"

        # Syntactic sugar to allow passing single string
        if isinstance(items, str):
            items = [items]

        # Add an extra column so we can give the first one extra space
        column_count = len(items) + 1
        column_size = round(Printer._output_width() / column_count)

        line = ''
        for idx, item in enumerate(items):
            if isinstance(item, dict):
                text = item['text']
                item_size = len(text)

                item = format_item(text, item['color'])
            else:
                item_size = len(item)
                item = format_item(item, color)

            if idx == 0:
                available_space = column_size * 2
                prefix_size = indent_level * 2
            else:
                available_space = column_size
                # prefix_size = 0 # Left justify
                # prefix_size = available_space - len(item) # Right justify
                prefix_size = round(
                    (available_space - item_size) / 2)  # Centre justify

            prefix = ' ' * prefix_size
            suffix = ' ' * (available_space - prefix_size - item_size)

            line += f'{prefix}{item}{suffix}'

        self.print(line.rstrip())

    def _output_width():
        try:
            return shutil.get_terminal_size().columns
        except:
            return 100

    def _format_duration(start: datetime, end: datetime):
        duration = end - start
        seconds = duration.total_seconds()
        if seconds >= 60:
            seconds_remaining = seconds % 60
            minutes = (seconds - seconds_remaining) / 60
            return "{0:.0f}m{1:.0f}s".format(minutes, seconds_remaining)
        elif seconds >= 1:
            return "{0:.2f}s".format(seconds)
        else:
            return "{0:.0f}ms".format(seconds * 1000)
