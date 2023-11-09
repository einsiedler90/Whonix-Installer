#!/bin/bash

## Copyright (C) 2023 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Developer script to allow easily only building the Windows-Installer.
## (Without building all of Whonix.)

set -x
set -e
set -o pipefail
set -o nounset

## Only on developer machine for local test builds only.
export use_ppcross_x64_maybe="--compiler=/usr/bin/ppcrossx64"
export skip_fpc_windows_dependencies_check="true"

export TARGET_SYSTEM="LINUX"

## hardcoded
export VERSION_FULL="Xfce-16.0.9.8"

# TODO: replace with linux equivalent
export FILE_LICENSE="../deps/license.txt"
export FILE_CLI_INSTALLER_SCRIPT="../deps/whonix-xfce-installer-cli"
export FILE_INSTALLER_BINARY_FINAL="build/whonix-xfce-installer-gui-$VERSION_FULL"

./build.sh

exit 0
