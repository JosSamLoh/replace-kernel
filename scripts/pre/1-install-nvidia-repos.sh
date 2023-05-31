#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

# Add rpmfusion repos
wget -P /tmp/rpms \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${RELEASE}.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${RELEASE}.noarch.rpm
printf "### RPMFusion repos installed ###\n"
