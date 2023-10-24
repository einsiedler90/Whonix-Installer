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

true "$0: START"

## 1) Requires various environment variables:
## See build-einsiedler.sh

if ! echo "WINDOWS LINUX" | grep -w -q "$TARGET_SYSTEM"; then
  echo "$0: ERROR: TARGET_SYSTEM must be either WINDOWS or LINUX." >&2
  exit 1
fi

## 2) sanity tests

command -v xmllint >/dev/null
command -v lazbuild >/dev/null
command -v ldd >/dev/null
## from package libfile-mimeinfo-perl
command -v mimetype >/dev/null

[[ -v skip_fpc_windows_dependencies_check ]] || skip_fpc_windows_dependencies_check=""
[[ -v use_ppcross_x64_maybe ]] || use_ppcross_x64_maybe=""

## If using
## export use_ppcross_x64_maybe="--compiler=/usr/bin/ppcrossx64"
## then this is not needed.
## This can maybe be removed from developer machines start using Debian trixie or higher?
if [ ! "$skip_fpc_windows_dependencies_check" = "true" ]; then
  ## lazbuild requires build dependency packages from Debian trixie.
  dpkg -l | grep fp-units-win-base >/dev/null
  dpkg -l | grep fp-units-win-rtl >/dev/null
  dpkg -l | grep fp-units-win-fcl >/dev/null
  dpkg -l | grep fp-units-win-misc >/dev/null
fi

## Debugging.
pwd

if [ "$TARGET_SYSTEM" = "WINDOWS" ]; then
  for fso in "$FILE_LICENSE" "$FILE_WHONIX_OVA" "$FILE_WHONIX_STARTER_MSI" "$FILE_VBOX_INST_EXE" ; do
    test -r "$fso"
  done
fi
if [ "$TARGET_SYSTEM" = "LINUX" ]; then
  for fso in "$FILE_LICENSE" "$FILE_CLI_INSTALLER_SCRIPT" ; do
    test -r "$fso"
  done
fi

## 3) set current whonix OVA size in INI file for main installer executable

if [ "$TARGET_SYSTEM" = "WINDOWS" ]; then
  FILE_WHONIX_OVA_SIZE=$(stat -c%s "$FILE_WHONIX_OVA")
else
  FILE_WHONIX_OVA_SIZE="0"
fi

echo "\
[general]
size=$FILE_WHONIX_OVA_SIZE
" | tee "WhonixOvaInfo.ini" >/dev/null

## Debugging.
cat "WhonixOvaInfo.ini"

## 4.0) rename original lpi file

## NOTE: We cannot rename the original WhonixInstaller.lpi to WhonixInstaller.lpi.in,
##       because then this source code could no longer be compiled with the
##       lazarus GUI.

mv "WhonixInstaller.lpi" "WhonixInstaller.lpi.in"
cp "WhonixInstaller.lpi.in" "WhonixInstaller.lpi"

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
set $FILE_INSTALLER_BINARY_FINAL
save" | xmllint --shell "WhonixInstaller.lpi"

## 4.2) update resources in lpi file

if [ "$TARGET_SYSTEM" = "WINDOWS" ]; then
  echo -e "\
  cd //Resources/Resource_2[@ResourceName='LICENSE']/@FileName
  set $FILE_LICENSE
  cd //Resources/Resource_5[@ResourceName='VBOX']/@FileName
  set $FILE_VBOX_INST_EXE
  cd //Resources/Resource_6[@ResourceName='STARTER']/@FileName
  set $FILE_WHONIX_STARTER_MSI
  save" | xmllint --shell "WhonixInstaller.lpi"
fi
if [ "$TARGET_SYSTEM" = "LINUX" ]; then
  echo -e "\
  cd //Resources/Resource_2[@ResourceName='LICENSE']/@FileName
  set $FILE_LICENSE
  cd //Resources/Resource_3[@ResourceName='SCRIPT']/@FileName
  set $FILE_CLI_INSTALLER_SCRIPT
  save" | xmllint --shell "WhonixInstaller.lpi"
fi

#cp "$FILE_LICENSE" "LICENSE"
#cp "$FILE_VBOX_INST_EXE" "VBoxSetup.exe"
#cp "$FILE_WHONIX_STARTER_MSI" "WhonixStarterInstaller.msi"

## 5.0) build static library libQt5Pas.a

if [ "$TARGET_SYSTEM" = "LINUX" ]; then
  apt-get source libqt5pas-dev

  matching_dirs=$(find . -maxdepth 1 -type d -name 'libqtpas*')
  first_dir=$(echo "$matching_dirs" | head -n1)
  cd "$first_dir"

  test -r Qt5Pas.pro
  sed -i '/^TEMPLATE = lib/a CONFIG += staticlib' Qt5Pas.pro
  qmake
  make
  cp libQt5Pas.a ..
  cd ..
  test libQt5Pas.a
fi

## 5.1) build executable WhonixInstaller.exe

true "use_ppcross_x64_maybe: $use_ppcross_x64_maybe"

if [ "$TARGET_SYSTEM" = "WINDOWS" ]; then
  lazbuild -B "WhonixInstaller.lpr" --cpu=x86_64 --os=win64 "$use_ppcross_x64_maybe"
fi
if [ "$TARGET_SYSTEM" = "LINUX" ]; then
  lazbuild -B "WhonixInstaller.lpr" --ws=qt5 --cpu=x86_64 --os=linux "$use_ppcross_x64_maybe"
fi

## 5.2) restore original lpi file and delete backup

rm "WhonixInstaller.lpi"
mv "WhonixInstaller.lpi.in" "WhonixInstaller.lpi"

## 6) append Whonix OVA to WhonixInstaller.exe

if [ "$TARGET_SYSTEM" = "WINDOWS" ]; then
  cat "WhonixInstaller.exe" "$FILE_WHONIX_OVA" | tee "$FILE_INSTALLER_BINARY_FINAL" >/dev/null
fi
if [ "$TARGET_SYSTEM" = "LINUX" ]; then
  cp "WhonixInstaller" "$FILE_INSTALLER_BINARY_FINAL"
fi

## Debugging.
du -sh "$FILE_INSTALLER_BINARY_FINAL"
mimetype "$FILE_INSTALLER_BINARY_FINAL"

if [ "$TARGET_SYSTEM" = "LINUX" ]; then
  if ldd "$FILE_INSTALLER_BINARY_FINAL" | grep -q "Qt5Pas"; then
    false "$0: ERROR: $FILE_INSTALLER_BINARY_FINAL depends on QT5Pas"
  fi
fi

true "$0: SUCCESS"

exit 0
