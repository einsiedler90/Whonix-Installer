#!/bin/bash

## Copyright (C) 2023 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Developer script to allow easily only building the Windows-Installer.
## (Without building all of Whonix.)

## /home/user is hardcoded, because wixl breaks with path '/github/[...]'.
## Couldn't find file /github/home/windows-installer-dummy-temp-delete-me/Whonix.exe
## Might be wrong. Could be different issue.
## ~/windows-installer-dummy-temp-delete-me might work fine.

set -x
set -e
set -o pipefail
set -o nounset

whoami

export VERSION="16.0.4.2"
export INSTALLER_VERSION="210"
export MANUFACTURE="ENCRYPTED SUPPORT LP"
export DESCRIPTION="Whonix-Starter"

export FILE_LICENSE=/home/user/windows-installer-dummy-temp-delete-me/license.txt
export FILE_WHONIX_OVA=/home/user/windows-installer-dummy-temp-delete-me/Whonix-XFCE-16.0.9.8.ova
export FILE_WHONIX_EXE=/home/user/windows-installer-dummy-temp-delete-me/Whonix.exe
export FILE_VBOX_INST_EXE=/home/user/windows-installer-dummy-temp-delete-me/vbox.exe
export FILE_INSTALLER_BINARY_WITH_APPENDED_OVA=/home/user/windows-installer-dummy-temp-delete-me/WhonixSetup-XFCE.exe

rm --recursive --force /home/user/windows-installer-dummy-temp-delete-me

mkdir --parents /home/user/windows-installer-dummy-temp-delete-me

for fso in "$FILE_LICENSE" "$FILE_WHONIX_OVA" "$FILE_WHONIX_EXE" "$FILE_VBOX_INST_EXE" ; do
  touch "$fso"
  test -r "$fso"
done

rm --force "$FILE_WHONIX_EXE"
wget -O "$FILE_WHONIX_EXE" "https://github.com/Whonix/Whonix-Starter-Binary/raw/master/Whonix.exe"

## Debugging.
realpath /home/user/windows-installer-dummy-temp-delete-me/*
ls -la "$FILE_WHONIX_EXE"
test -r "$FILE_WHONIX_EXE"
#tail -n 3 "$FILE_WHONIX_EXE"

./build.sh

exit 0
