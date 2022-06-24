#!/bin/bash

set -eox pipefail

# Get version
shopt -s xpg_echo
VERSION=`cat /etc/centos-release | sed -e "s/'//g" | sed -e 's/"//g'`

# Echo Version
echo "'OS: ${VERSION}'"
