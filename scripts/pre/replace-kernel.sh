#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

# Set UNWANTED_PACKAGES=$(Query all installed packages listed as package names
# only | grab entire lines containing 'kernel-tools' and
# 'virtualbox-guest-additions')
# UNWANTED_PACKAGES="$(rpm -qa --qf "%{NAME}\n" | grep -P '^(?=kernel-tools|virtualbox|kmod)')"
# printf "### Packages to be removed ###\n$UNWANTED_PACKAGES\n\n"

# Set INSTALLED_KERNEL_PACKAGES=$(Query all installed packages listed as
# package names only | grab entire lines beginning with 'kernel*' except
# 'kernel-tools')
INSTALLED_KERNEL_PACKAGES="$(rpm -qa --qf "%{NAME}\n" | grep -P '^kernel(?!-tools).*')"
printf "### Packages to be replaced ###\n$INSTALLED_KERNEL_PACKAGES\n\n"

# Automatically determine which Fedora version we"re building.
# Taken from build.sh - shortened
FEDORA_VERSION="$(cat /usr/lib/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
printf "### Fedora version ###\n$FEDORA_VERSION\n\n"

# Download all files recursively from repo and output to /tmp/fsync-kernel-images
wget -rc -np -nH -nd --random-wait -P "/tmp/fsync-kernel-images/" \
	https://download.copr.fedorainfracloud.org/results/sentry/kernel-fsync/fedora-$FEDORA_VERSION-x86_64/
printf "### kernel-fsync packages installed into ###\n/tmp/fsync-kernel-images/\n\n"

# Move into the directory containing the sentry/kernel-fsync files
cd /tmp/fsync-kernel-images/

rpm-ostree cliwrap install-to-root / && \
rpm-ostree override replace \
    $(echo $INSTALLED_KERNEL_PACKAGES | \
    sed -e 's/^/.\//' | \
    sed -e 's/ /-[0-9]*[^src].rpm .\//g' | \
    sed -e 's/$/-[0-9]*[^src].rpm/') #\
    #$(echo $UNWANTED_PACKAGES | \
    #sed -e 's/^/--remove=/' | \
    #sed -e 's/ / --remove=/g')

# Exit the directory
cd ..

# Cleanup
rm -r /tmp/fsync-kernel-images/
printf "### Kernel replaced, temp files cleaned up ###"