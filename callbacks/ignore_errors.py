from __future__ import print_function
from ansible.plugins.callback import CallbackBase


class CallbackModule(CallbackBase):
    def v2_playbook_on_start(self, playbook):
        """
        Dynamically set the `ignore_errors` property of each role to `True` so that an error in one role
        will not prevent subsequent roles from running
        """
        plays = playbook.get_plays()

        # Note: Although identical roles are shared between plays we cannot deduplicate them,
        # since Ansible treats them as different objects internally
        roles = [role for play in plays for role in play.get_roles()]

        # Note: Tags for roles are set dynamically in `_load_role_data` instead of in __init__
        # I don't know why they do that.
        for role in roles:
            role.ignore_errors = True
