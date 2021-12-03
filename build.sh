#!/bin/bash
#set -x # Uncomment to Debug

rm *.tf
/usr/local/bin/md-tangle ./Readme.md
/usr/local/bin/terraform fmt
