#!/usr/bin/env python

import os
from shutil import which
from subprocess import run
from sys import exit


def get_file_path(file):
    return os.path.join(os.path.dirname(__file__), file)


def apt(packages):
    ppas_file = get_file_path('ppa')

    with open(ppas_file) as f:
        ppas = [line.rstrip() for line in f]
        for ppa in ppas:
            run(['sudo', 'add-apt-repository', f'ppa:{ppa}'])

    run(['sudo', 'apt', 'update'])

    run(['sudo', 'apt', 'install', '-y', '--ignore-missing'] + packages)


def dnf(packages):
    coprs_file = get_file_path('copr')

    with open(coprs_file) as f:
        coprs = [line.rstrip() for line in f]
        for copr in coprs:
            run(['sudo', 'dnf', 'copr', 'enable', '-y', copr])

    # Add Microsoft repository for VSCode
    run(['sudo', 'rpm', '--import', 'https://packages.microsoft.com/keys/microsoft.asc'])
    # TODO: write vscode.repo to /etc/yum.repos.d

    # Update repositories
    run(['sudo', 'dnf', 'check-update'])

    run(['sudo', 'dnf', 'install', '-y',  '--skip-broken'] + packages)


def pacman(packages):
    pass


def main():
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
            exit(1)


if __name__ == '__main__':
    main()
