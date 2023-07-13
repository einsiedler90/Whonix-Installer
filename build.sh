#!/bin/bash

## Copyright (C) 2023 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## This script will be called by:
## dm-prepare-release
## https://github.com/Kicksecure/developer-meta-files/blob/master/usr/bin/dm-prepare-release

set -x
set -e
set -o pipefail
set -o nounset

## 1) Requires various environment variables:
## See build-einsiedler.sh

## 2) sanity tests

true "$0: START"

if ! [ -x "$(command -v xmllint)" ]; then
  echo "$0: ERROR: xmllint is not installed." >&2
  exit 1
fi

if ! [ -x "$(command -v lazbuild)" ]; then
  echo "$0: ERROR: lazbuild is not installed." >&2
  exit 1
fi

## Debugging.
pwd

for fso in "$FILE_LICENSE" "$FILE_WHONIX_OVA" "$FILE_WHONIX_STARTER_MSI" "$FILE_VBOX_INST_EXE" ; do
  test -r "$fso"
done

## 3) set current whonix OVA size in INI file for main setup executable

FILE_WHONIX_OVA_SIZE=$(stat -c%s "$FILE_WHONIX_OVA")

echo "\
[general]
size=$FILE_WHONIX_OVA_SIZE
" | tee "WhonixOvaInfo.ini" >/dev/null

## Debugging.
cat "WhonixOvaInfo.ini"

## 4.0) rename original lpi file

## NOTE: We cannot rename the original WhonixSetup.lpi to WhonixSetup.lpi.in,
##       because then this source code could no longer be compiled with the
##       lazarus GUI.

mv "WhonixSetup.lpi" "WhonixSetup.lpi.in"
cp "WhonixSetup.lpi.in" "WhonixSetup.lpi"

## 4.1) update lpi file

echo -e "\
cd //VersionInfo/MajorVersionNr/@Value
set $VERSION_MAJOR
cd //VersionInfo/MinorVersionNr/@Value
set $VERSION_MINOR
cd //VersionInfo/RevisionNr/@Value
set $VERSION_REVISION
cd //VersionInfo/BuildNr/@Value
set $VERSION_BUILD
cd //VersionInfo/StringTable/@ProductVersion
set $VERSION_FULL
cd //VersionInfo/StringTable/@OriginalFilename
set $FILE_INSTALLER_BINARY_WITH_APPENDED_OVA
save" | xmllint --shell "WhonixSetup.lpi"

## 4.2) update resources in lpi file

echo -e "\
cd //Resources/Resource_1[@ResourceName='LICENSE']/@FileName
set $FILE_LICENSE
cd //Resources/Resource_2[@ResourceName='VBOX']/@FileName
set $FILE_VBOX_INST_EXE
cd //Resources/Resource_4[@ResourceName='STARTER']/@FileName
set $FILE_WHONIX_STARTER_MSI
save" | xmllint --shell "WhonixSetup.lpi"

#cp "$FILE_LICENSE" "LICENSE"
#cp "$FILE_VBOX_INST_EXE" "VBoxSetup.exe"
#cp "$FILE_WHONIX_STARTER_MSI" "WhonixStarterSetup.msi"

## 5.1) build executable WhonixSetup.exe

lazbuild -B "WhonixSetup.lpr" --cpu=x86_64 --os=win64 --compiler=/usr/bin/ppcrossx64

## 5.2) restore original lpi file and delete backup

rm "WhonixSetup.lpi"
mv "WhonixSetup.lpi.in" "WhonixSetup.lpi"

ls -la "WhonixSetup.exe"
du -sh "WhonixSetup.exe"
mimetype "WhonixSetup.exe"

## 6) append Whonix OVA to WhonixSetup.exe

cat "WhonixSetup.exe" "$FILE_WHONIX_OVA" | tee "$FILE_INSTALLER_BINARY_WITH_APPENDED_OVA" >/dev/null

## Debugging.
ls -la "WhonixSetup.exe"
du -sh "$FILE_INSTALLER_BINARY_WITH_APPENDED_OVA"
mimetype "$FILE_INSTALLER_BINARY_WITH_APPENDED_OVA"

true "$0: SUCCESS"

exit 0
