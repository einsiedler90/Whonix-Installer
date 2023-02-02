#!/bin/bash

set -x
set -e

VERSION="16.0.4.2-empty"
INSTALLER_VERSION="200"
MANUFACTURE="ENCRYPTED SUPPORT LP"
DESCRIPTION="Whonix Starter"

FILE_LICENSE="../deps/license.txt"
FILE_WHONIX_OVA="../deps/Whonix.ova"
FILE_WHONIX_EXE="../deps/Whonix.exe"
FILE_VBOX_INST_EXE="../deps/vbox.exe"

if ! [ -x "$(command -v wixl)" ]; then
  echo "$0: ERROR wixl is not installed." >&2
  exit 1
fi

rm -f Whonix.msi

wixl -v --arch x64 \
  -D whonixVersion="$VERSION" \
  -D whonixInstallerVersion="$INSTALLER_VERSION" \
  -D whonixManufacturer="$MANUFACTURE" \
  -D whonixDescription="$DESCRIPTION" \
  -D whonixFileLicense="$FILE_LICENSE" \
  -D whonixFileOva="$FILE_WHONIX_OVA" \
  -D whonixFileMainExe="$FILE_WHONIX_EXE" \
  -D whonixFileVboxExe="$FILE_VBOX_INST_EXE" \
  Whonix.wxs
