#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

# Automatically determine which Fedora version were building.
# Taken from build.sh - shortened
FEDORA_VERSION="$(cat /usr/lib/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
printf "### Fedora version ###\n$FEDORA_VERSION\n\n"

# Get RPMFusion repo rpms
wget -P /tmp/rpmfusion-repos/ \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$FEDORA_VERSION.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$FEDORA_VERSION.noarch.rpm

rpm-ostree install \
    /tmp/rpmfusion-repos/rpmfusion-free-release-$FEDORA_VERSION.noarch.rpm \
    /tmp/rpmfusion-repos/rpmfusion-nonfree-release-$FEDORA_VERSION.noarch.rpm
