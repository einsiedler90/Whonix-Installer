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
export VERSION="16.0.9.8"
export MANUFACTURE="ENCRYPTED SUPPORT LP"
export DESCRIPTION="Whonix-Starter"

export FILE_LICENSE="../deps/license.txt"
#export FILE_WHONIX_OVA="../deps/Whonix.ova"
export FILE_WHONIX_OVA="../deps/Whonix-XFCE-16.0.9.8.ova"
export FILE_WHONIX_EXE="../deps/Whonix.exe"
export FILE_VBOX_INST_EXE="../deps/vbox.exe"
export FILE_INSTALLER_BINARY_WITH_APPENDED_OVA="WhonixSetup-XFCE-$VERSION.exe"

./build.sh

exit 0
