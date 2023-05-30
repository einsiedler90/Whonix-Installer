#!/bin/bash

## Copyright (C) 2023 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Developer script to allow easily only building the Windows-Installer.
## (Without building all of Whonix.)

set -x
set -e
set -o pipefail
set -o nounset

export VERSION="16.0.4.2"
export INSTALLER_VERSION="210"
export MANUFACTURE="ENCRYPTED SUPPORT LP"
export DESCRIPTION="Whonix-Starter"

export FILE_LICENSE=~/windows-installer-dummy-temp-delete-me/license.txt
export FILE_WHONIX_OVA=~/windows-installer-dummy-temp-delete-me/Whonix-XFCE-16.0.9.8.ova
export FILE_WHONIX_EXE=~/windows-installer-dummy-temp-delete-me/Whonix.exe
export FILE_VBOX_INST_EXE=~/windows-installer-dummy-temp-delete-me/vbox.exe
export FILE_INSTALLER_BINARY_WITH_APPENDED_OVA=~/windows-installer-dummy-temp-delete-me/WhonixSetup-XFCE.exe

rm --recursive --force ~/windows-installer-dummy-temp-delete-me

mkdir --parents ~/windows-installer-dummy-temp-delete-me

for fso in "$FILE_LICENSE" "$FILE_WHONIX_OVA" "$FILE_WHONIX_EXE" "$FILE_VBOX_INST_EXE" ; do
  touch "$fso"
  test -r "$fso"
done

## Debugging.
realpath ~/windows-installer-dummy-temp-delete-me/*

./build.sh

exit 0
