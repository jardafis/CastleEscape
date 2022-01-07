#!/bin/bash
grep _main *.map | sed -e 's/\$/0x/g' | awk '{printf "%d", strtonum($3)}'
