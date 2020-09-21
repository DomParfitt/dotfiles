#!/usr/bin/env python

import os
from shutil import which
from subprocess import run
from sys import version_info, exit


def get_file_path(file):
    return os.path.join(os.path.dirname(__file__), file)


def apt(packages):
    # Append apt specific packages
    apt_file = get_file_path('dnf')
    with open(apt_file) as f:
        packages += [line.rstrip() for line in f]

    # Enable required PPAs
    ppas_file = get_file_path('ppa')
    with open(ppas_file) as f:
        ppas = [line.rstrip() for line in f]
        for ppa in ppas:
            run(['add-apt-repository', f'ppa:{ppa}'])

    # Update the package lists
    run(['apt', 'update'])

    # Install packages
    run(['apt', 'install', '-y', '--ignore-missing'] + packages)


def dnf(packages):
    # Append dnf specific packages
    dnf_file = get_file_path('dnf')
    with open(dnf_file) as f:
        packages += [line.rstrip() for line in f]

    # Enable required COPRs
    coprs_file = get_file_path('copr')
    with open(coprs_file) as f:
        coprs = [line.rstrip() for line in f]
        for copr in coprs:
            run(['dnf', 'copr', 'enable', '-y', copr])

    # Add Microsoft repository for VSCode
    run(['rpm', '--import', 'https://packages.microsoft.com/keys/microsoft.asc'])

    # TODO: Not sure if this will work because of root privileges
    with open('/etc/yum.repos.d/vscode.repo', 'w') as f:
        f.write('[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc')

    # Update repositories
    run(['dnf', 'check-update'])

    # Install packages
    run(['dnf', 'install', '--assumeyes',  '--skip-broken'] + packages)


def pacman(packages):
    pass


def main():
    if version_info.major != 3:
        print(
            f'Python 3 required. Current version is {version_info.major}.{version_info.minor}.{version_info.micro}')
        exit(1)

    if os.geteuid() != 0:
        print('Script must be run with sudo')
        exit(2)

    packages_file = get_file_path('main')

    with open(packages_file) as f:
        packages = [line.rstrip() for line in f]
        print(packages)
        if which('dnf') is not None:
            dnf(packages)
        elif which('apt') is not None:
            apt(packages)
        elif which('pacman') is not None:
            pacman(packages)
        else:
            print('Unknown package manager')
            exit(3)


if __name__ == '__main__':
    main()
