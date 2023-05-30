#!/bin/bash

set -x
set -e
set -o pipefail
set -o nounset

export VERSION="16.0.9.8"
export INSTALLER_VERSION="210" # increase for every different VERSION
export MANUFACTURE="ENCRYPTED SUPPORT LP"
export DESCRIPTION="Whonix-Starter"

export ILE_LICENSE="../deps/license.txt"
#export FILE_WHONIX_OVA="../deps/Whonix.ova"
export FILE_WHONIX_OVA="../deps/Whonix-XFCE-16.0.9.8.ova"
export FILE_WHONIX_EXE="../deps/Whonix.exe"
export FILE_VBOX_INST_EXE="../deps/vbox.exe"

./build.sh

exit 0
