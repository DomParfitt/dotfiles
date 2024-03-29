from ansible.plugins.callback import CallbackBase
from ansible.utils.color import stringc
from datetime import datetime
import shutil
from enum import Enum


DOCUMENTATION = '''
    name: pretty_print
    type: stdout
    description: Pretty prints playbook output
    short_description: Pretty prints playbook output.
    options:
        show_skipped:
            name: Show skipped
            description: Include skipped tasks in the output.
            type: bool
            default: False
            ini:
                - section: callback_pretty_print
                  key: show_skipped
            env:
                - name: ANSIBLE_CALLBACK_PRETTY_PRINT_SHOW_SKIPPED
            vars:
                - name: show_skipped
        show_msgs:
            name: Show messages
            description: Print msgs from tasks
            type: bool
            default: True
            ini:
                - section: callback_pretty_print
                  key: show_msgs
            env:
                - name: ANSIBLE_CALLBACK_PRETTY_PRINT_SHOW_MSGS
        justify:
            name: Justify
            description: How to justify the output.
            type: string
            default: centre
            choices:
                - centre
                - left
                - right
            ini:
                - section: callback_pretty_print
                  key: justify
            env:
                - name: ANSIBLE_CALLBACK_PRETTY_PRINT_JUSTIFY

'''


class CallbackModule(CallbackBase):

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'pretty_print'

    _current_role = None
    _current_task = None
    _current_pseudo_parent = None
    _parent_stack = []
    _processed_roles = []

    def __init__(self):
        super(CallbackModule, self).__init__()

    def v2_playbook_on_play_start(self, play):
        self._start = datetime.now()
        self._show_skipped = self.get_option('show_skipped')
        self._show_msgs = self.get_option('show_msgs')

        printer_args = {}
        printer_args['justify'] = self.get_option('justify')
        self.printer = Printer(self._display.display, printer_args)

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

        parent = task.get_first_parent_include()
        pseudo_parent = None
        if parent is not None:
            parent = self._get_parent(parent.name)
            if parent is not None:
                task_filepath = task.get_path().split(":")[0]
                task_file_name = self._name_from_filepath(task_filepath)
                if task_file_name in parent['included_files']:
                    pseudo_parent = {
                        "name": task_file_name,
                        "result": Result.NONE,
                        "msg": None,
                    }

        self._current_task = {
            "name": task.name,
            "start": datetime.now(),
            "parent": parent,
            "pseudo_parent": pseudo_parent,
            "included_files": [],
        }

    def v2_playbook_on_stats(self, stats):
        self._on_role_end()
        self.printer.print_summary(self._start, self._processed_roles)

    def v2_runner_on_ok(self, result):
        if result.is_changed():
            res = Result.CHANGED
        else:
            res = Result.SUCCESS

        included_files = self._include_files_from_result(result)
        if included_files is not None:
            res = Result.NONE
            self._current_task['included_files'] = included_files

        self._on_task_end(res, self._msg_from_result(result))

    def v2_runner_on_skipped(self, result):
        self._on_task_end(Result.SKIPPED, self._msg_from_result(result))

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self._on_task_end(
            Result.FAILED, self._msg_from_result(result, force=True))

    def v2_on_file_diff(self, result):
        self._on_task_end(Result.CHANGED, self._msg_from_result(result))

    def _on_role_start(self, role_name):
        self._current_role = {
            "name": role_name,
            "tasks": [],
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
        # role name first. Done here rather than _on_role_start so we don't print a role name when
        # all tasks are skipped
        if len(self._current_role['tasks']) == 0:
            self.printer.print_role_name(self._current_role['name'])

        self._current_task['result'] = result
        self._current_task['end'] = datetime.now()
        self._current_task['msg'] = msg
        self._current_role['tasks'].append(self._current_task)

        self._update_parent_stack(self._current_task)

        pseudo_parent = self._current_task['pseudo_parent']
        indent_level = len(self._parent_stack) + 1
        if pseudo_parent is not None:
            if pseudo_parent != self._current_pseudo_parent:
                self.printer.print_task(
                    self._current_task['pseudo_parent'], indent_level)
            self.printer.print_task(
                self._current_task, indent_level=indent_level+1)
            self._current_pseudo_parent = pseudo_parent
        else:
            self.printer.print_task(self._current_task, indent_level)

    def _update_parent_stack(self, task):
        parentTask = task['parent']
        if parentTask is None:
            self._parent_stack = []
            return

        # Treat tasks with a parent that is not a task we've seen (i.e. those added with `import_tasks`)
        # as having no parent.
        if parentTask['name'] not in [task['name'] for task in self._current_role['tasks']]:
            return

        if len(self._parent_stack) == 0:
            self._parent_stack.append(parentTask)
            return

        currentParent = self._parent_stack[-1]
        if currentParent['name'] != parentTask['name']:
            self._parent_stack.append(parentTask)

    def _msg_from_result(self, result, force=False):
        if not self._show_msgs:
            return None

        if '_ansible_verbose_always' not in result._result and not force:
            return None

        if 'results' not in result._result:
            return result._result['msg']

        failed_results = [
            result for result in result._result['results'] if result['failed']
        ]

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

    def _include_files_from_result(self, result):
        if 'results' not in result._result:
            return

        results = result._result['results']

        if len(results) == 0:
            return

        if 'include' not in results[0]:
            return

        includes = []
        for result in results:
            if 'include' not in result:
                continue

            filepath = result['include']
            includes.append(self._name_from_filepath(filepath))

        return includes

    def _name_from_filepath(self, filepath):
        name = str.split(filepath, '/')
        name = name[len(name) - 1]
        name = str.split(name, '.')
        return name[0]

    def _get_parent(self, parent_name):
        tasks = self._current_role['tasks']
        for task in tasks:
            if task['name'] == parent_name:
                return task


class Printer:

    def __init__(self, print, args):
        self.print = print
        self._justify = args['justify']

    def debug(self, obj):
        import pprint
        self.print(pprint.pformat(obj))

    def print_role_name(self, role_name):
        self._print_line()
        self._print_line(role_name, bold=True)

    def print_task(self, task, indent_level=1):
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
                if self._justify == 'left':
                    prefix_size = 0
                elif self._justify == 'right':
                    prefix_size = available_space - item_size
                else:
                    prefix_size = round((available_space - item_size) / 2)

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
