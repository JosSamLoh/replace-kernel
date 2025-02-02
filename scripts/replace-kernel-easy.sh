#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

FEDORA_VERSION="$(cat /usr/lib/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
INSTALLED_KERNEL_PACKAGES="$(rpm -qa --qf "%{NAME}\n" | grep -P '^kernel(?!-tools).*')"

printf "### Fedora version ###\n$FEDORA_VERSION\n\n"

# Add required kernel repo
# Run script with sudo or add sudo to below if using script locally
wget -P /etc/yum.repos.d/ \
    "https://copr.fedorainfracloud.org/coprs/rmnscnce/kernel-xanmod/repo/fedora-$FEDORA_VERSION/rmnscnce-kernel-xanmod-fedora-$FEDORA_VERSION.repo"
# wget -P /etc/yum.repos.d/ ".REPO URL"

printf "### Packages to be replaced ###\n$INSTALLED_KERNEL_PACKAGES\n\n"
sleep 2

# Use rpm-ostree's cliwrap to allow dracut to run on the container and generate
# an initramfs.
### COMMENT OUT BELOW LINE IF USING LOCALLY ###
rpm-ostree cliwrap install-to-root / && \
rpm-ostree override remove $INSTALLED_KERNEL_PACKAGES --install=kernel-xanmod-edge
# rpm-ostree override remove $INSTALLED_KERNEL_PACKAGES --install=kernel-specified
# rpm-ostree override replace "URL/kernel-name.rpm"

#
## This script is best for repos which have named their packages nicely, like
## XanMod, where the above remove/replace lines usually work without issues and
## pulling files from the repo isn't necessary
#
