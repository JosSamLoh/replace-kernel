#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

# Automatically determine which Fedora version we"re building.
# Taken from build.sh - shortened
FEDORA_VERSION="$(cat /usr/lib/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
printf "### Fedora version ###\n$FEDORA_VERSION\n"

# Add rpmfusion repos
wget -P /tmp/rpms \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$FEDORA_VERSION.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$FEDORA_VERSION.noarch.rpm
printf "### RPMFusion repos installed ###\n"
