from __future__ import print_function
from ansible.plugins.callback import CallbackBase

DOCUMENTATION = '''
    name: ignore_errors
    type: callback
    description: Sets the `ignore_errors` property of each role in the playbook so that an error in one role will not prevent subsequent roles from running
    short_description: Sets the `ignore_errors` property of each role in the playbook 
    options:
        enabled:
            name: Enabled
            description: Enable the plugin.
            ini:
                - section: callback_ignore_errors
                  key: enabled
            env:
                - name: ANSIBLE_CALLBACK_IGNORE_ERRORS_ENABLED
            default: True
            type: bool
'''


class CallbackModule(CallbackBase):
    def v2_playbook_on_start(self, playbook):
        if not self.get_option('enabled'):
            return

        plays = playbook.get_plays()

        # Note: Although identical roles are shared between plays we cannot deduplicate them,
        # since Ansible treats them as different objects internally
        roles = [role for play in plays for role in play.get_roles()]

        # Note: Tags for roles are set dynamically in `_load_role_data` instead of in __init__
        # I don't know why they do that.
        for role in roles:
            role.ignore_errors = True
