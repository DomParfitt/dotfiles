from ansible.plugins.callback import CallbackBase
from datetime import datetime
import shutil
import subprocess
import os


class CallbackModule(CallbackBase):

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'pretty_print'

    _current_role = None
    _current_task = None
    _processed_roles = []
    _start = datetime.now()

    def __init__(self):
        super(CallbackModule, self).__init__()

    def v2_playbook_on_task_start(self, task, is_conditional):
        if task._role is None:
            return

        role_name = task._role._role_name
        # if task.get_first_parent_include() is not None:
        #     self._print_role_name(f'{role_name} -> fedora')

        if self._current_role is None:
            self._on_role_start(role_name)
        elif self._current_role['name'] != role_name:
            self._on_role_end()

            self._on_role_start(role_name)

        self._current_task = {
            "name": task.name,
            "start": datetime.now()
        }

    def v2_runner_on_ok(self, result):
        if result.is_changed():
            self._on_task_end('CHANGED')
        else:
            self._on_task_end('SUCCESS')

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self._current_role['result'] = 'FAILED'
        self._on_task_end('FAILED')
        self._tabulate_line(
            # [italic("".join(result._result['msg']))],
            [italic(result._result)],
            color=result_color('FAILED'),
            indent_level=2
        )

    def v2_on_file_diff(self, result):
        self._on_task_end('CHANGED')

    def v2_runner_on_skipped(self, result):
        self._on_task_end('SKIPPED')

    def v2_playbook_on_stats(self, stats):
        self._on_role_end()

        self._print_summary()
        # hosts = stats.processed.keys()
        # for host in hosts:
        # for role in self._processed_roles:
        #     self._print_role(role)

        # self._display.display(f'\n')
        # self._display.display(f'{host} - {stats.summarize(host)}')

    def _on_role_start(self, role_name):
        self._print_role_name(role_name)
        self._current_role = {
            "name": role_name,
            "tasks": [],
            "result": 'SUCCESS',
            "start": datetime.now()
        }

    def _on_role_end(self):
        self._current_role['end'] = datetime.now()
        self._processed_roles.append(self._current_role)

    def _on_task_end(self, result):
        if self._current_task is None:
            return
        self._current_task['result'] = result
        self._current_task['end'] = datetime.now()
        self._current_role['tasks'].append(self._current_task)

        if result == 'SKIPPED':
            return

        self._print_task(self._current_task)

    def _print_summary(self):
        self._display.display(f'\n')
        self._display.display(bold('SUMMARY'))
        for role in self._processed_roles:
            self._print_role(role)

        self._display.display(
            f'  -----------------------------------------',
        )
        self._tabulate_line(
            ["TOTAL", duration(self._start, datetime.now()), ""],
        )
        self._display.display(f'\n')
        # self._display.display(f'{host} - {stats.summarize(host)}')

    def _print_role(self, role, print_tasks=False):
        name = role['name']
        result = role['result']
        start = role['start']
        end = role['end']

        self._tabulate_line(
            [name,  duration(start, end), ""],
            color=result_color(result)
        )

    def _print_role_name(self, role_name):
        self._display.display(bold(role_name))

    def _print_task(self, task):
        name = task['name']
        result = task['result']
        start = task['start']
        end = task['end']

        self._tabulate_line(
            [name, result, duration(start, end)],
            color=result_color(result)
        )

    def _tabulate_line(self, items, color='white', indent_level=1):
        indent = indent_level * 2 * ' '
        line = indent
        column_size = round(output_width() / len(items))
        for item in items:
            line += f'{item}{spacing(item, desired_spacing=column_size)}'

        self._display.display(line.rstrip(), color=color)


def result_color(result):
    if result == 'SUCCESS':
        return 'green'
    elif result == 'SKIPPED':
        return'blue'
    elif result == 'CHANGED':
        return 'yellow'
    elif result == 'FAILED':
        return 'red'
    else:
        return 'white'


def output_width():
    try:
        return shutil.get_terminal_size().columns
    except:
        return 100


def spacing(first_entry, desired_spacing=25):
    return ' ' * (desired_spacing - len(first_entry))


def bold(string):
    return f'\033[1m{string}\033[0m'


def italic(string):
    return f'\033[2m{string}\033[0m'


def duration(start, end):
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
