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

rm -f ./Whonix.msi

wixl \
  --verbose \
  --arch x64 \
  --define whonixVersion="$VERSION" \
  --define whonixInstallerVersion="$INSTALLER_VERSION" \
  --define whonixManufacturer="$MANUFACTURE" \
  --define whonixDescription="$DESCRIPTION" \
  --define whonixFileLicense="$FILE_LICENSE" \
  --define whonixFileOva="$FILE_WHONIX_OVA" \
  --define whonixFileMainExe="$FILE_WHONIX_EXE" \
  --define whonixFileVboxExe="$FILE_VBOX_INST_EXE" \
  --output ./Whonix.msi \
  Whonix.wxs
