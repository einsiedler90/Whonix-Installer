#!/bin/bash

set -x
set -e
set -o pipefail
set -o nounset

VERSION="16.0.9.8"
INSTALLER_VERSION="210" # increase for every different VERSION
MANUFACTURE="ENCRYPTED SUPPORT LP"
DESCRIPTION="Whonix-Starter"

FILE_LICENSE="../deps/license.txt"
#FILE_WHONIX_OVA="../deps/Whonix.ova"
FILE_WHONIX_OVA="../deps/Whonix-XFCE-16.0.9.8.ova"
FILE_WHONIX_EXE="../deps/Whonix.exe"
FILE_VBOX_INST_EXE="../deps/vbox.exe"

# 1) build msi package for whonix starter

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
  --define whonixFileMainExe="$FILE_WHONIX_EXE" \
  --output WhonixStarterSetup.msi \
  WhonixStarterSetup.wxs

# 2) set current whonix OVA size in INI file for main setup executable

FILE_WHONIX_OVA_SIZE=$(stat -c%s "$FILE_WHONIX_OVA")
printf "[general]\nsize=$FILE_WHONIX_OVA_SIZE" | tee "WhonixOvaInfo.ini" >/dev/null

# 3) update resource files

cp "$FILE_LICENSE" LICENSE
cp "$FILE_VBOX_INST_EXE" VBoxSetup.exe

# 3) build executable WhonixSetup.exe

lazbuild -B WhonixSetup.lpr --cpu=x86_64 --os=win64 --compiler=/usr/bin/ppcrossx64

# 4) append Whonix OVA to WhonixSetup.exe

cat WhonixSetup.exe "$FILE_WHONIX_OVA" | tee "WhonixSetup-XFCE-$VERSION.exe" >/dev/null

exit 0
