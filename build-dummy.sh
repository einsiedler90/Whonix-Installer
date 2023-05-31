#!/bin/bash

## Copyright (C) 2023 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Developer script to allow easily only building the Windows-Installer.
## (Without building all of Whonix.)

set -x
set -e
set -o pipefail
set -o nounset

# VERSION string must start with major.minor.build, rest will be ignored
export VERSION="16.0.4.2"
export MANUFACTURE="ENCRYPTED SUPPORT LP"
export DESCRIPTION="Whonix-Starter"

## All files are created created as empty files using `touch` for the purpose of
## simulated local or CI builds only.
export FILE_LICENSE=~/windows-installer-dummy-temp-delete-me/license.txt
export FILE_WHONIX_OVA=~/windows-installer-dummy-temp-delete-me/Whonix-XFCE-16.0.9.8.ova
export FILE_WHONIX_STARTER_MSI=~/windows-installer-dummy-temp-delete-me/WhonixStarterSetup.msi
export FILE_VBOX_INST_EXE=~/windows-installer-dummy-temp-delete-me/vbox.exe
export FILE_INSTALLER_BINARY_WITH_APPENDED_OVA=~/windows-installer-dummy-temp-delete-me/WhonixSetup-XFCE.exe

rm --recursive --force ~/windows-installer-dummy-temp-delete-me

mkdir --parents ~/windows-installer-dummy-temp-delete-me

for fso in "$FILE_LICENSE" "$FILE_WHONIX_OVA" "$FILE_WHONIX_STARTER_MSI" "$FILE_VBOX_INST_EXE" ; do
  touch "$fso"
done

./build.sh

exit 0
