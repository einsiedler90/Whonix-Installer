#!/bin/bash
VERSION="16.0.4.2-empty"
INSTALLER_VERSION="200"
MANUFACTURE="ENCRYPTED SUPPORT LP"
DESCRIPTION="Whonix Starter"

if ! [ -x "$(command -v wixl)" ]; then
  echo 'Error: wixl is not installed.' >&2
  exit 1
fi

rm Whonix.msi
wixl -v --arch x64 \
  -D whonixVersion="$VERSION" \
  -D whonixInstallerVersion="$INSTALLER_VERSION" \
  -D whonixManufacturer="$MANUFACTURE" \
  -D whonixDescription="$DESCRIPTION" \
  Whonix.wxs
  
exit 0
