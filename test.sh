#!/bin/bash

## Copyright (C) 2023 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

set -x
set -e
set -o pipefail
set -o nounset

fpc -Twin64 -Fi/usr/share/fpcsrc/3.2.2/rtl/win64 -Fi/usr/share/fpcsrc/3.2.2/rtl/win -Fi/usr/share/fpcsrc/3.2.2/rtl/inc -Fi/usr/share/fpcsrc/3.2.2/rtl/x86_64 -Fu/usr/share/fpcsrc/3.2.2/rtl/win64 -Fu/usr/share/fpcsrc/3.2.2/rtl/inc -FU/tmp/rtl -FE/tmp test
