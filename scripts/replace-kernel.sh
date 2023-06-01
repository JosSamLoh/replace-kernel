#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

# Set UNWANTED_PACKAGES=$(Query all installed packages listed as package names
# only | grab lines containing 'kernel-tools', 'virtualbox', 'kmod-nvidia')
UNWANTED_PACKAGES="$(rpm -qa --qf "%{NAME}\n" | grep -P '(?=kernel-tools|virtualbox|kmod-nvidia)')"
if [[ "$?" != 0 ]]; then
    printf "### No problematic packages installed! ###\n\n"
    sleep 1
else
    printf "### Packages are installed which may cause dependency issues ###\n$UNWANTED_PACKAGES\n\n"
    sleep 2
fi

# Set INSTALLED_KERNEL_PACKAGES=$(Query all installed packages listed as
# package names only | grab entire lines beginning with 'kernel*' except
# 'kernel-tools')
INSTALLED_KERNEL_PACKAGES="$(rpm -qa --qf "%{NAME}\n" | grep -P '^kernel(?!-tools).*')"

# Automatically determine which Fedora version we"re building.
# Taken from build.sh - shortened
FEDORA_VERSION="$(cat /usr/lib/os-release | grep -Po '(?<=VERSION_ID=)\d+')"

printf "### Packages to be replaced ###\n$INSTALLED_KERNEL_PACKAGES\n\n"
printf "### Fedora version ###\n$FEDORA_VERSION\n\n"
sleep 2

# Download all files recursively from repo and output to
# /tmp/kernel-fsync - So far I've not found a way to specify specific
# files
# You may want to replace '/tmp' with another dir if using script locally, or
# you may risk running out of space
wget -nv -rc -np -nH -nd --random-wait -P "/tmp/kernel-fsync/" \
    "https://download.copr.fedorainfracloud.org/results/sentry/kernel-fsync/fedora-$FEDORA_VERSION-x86_64/"
printf "### kernel-fsync rpms installed into ###\n/tmp/kernel-fsync/\n\n"
sleep 1

# Move into the directory containing the sentry/kernel-fsync files
cd /tmp/kernel-fsync/

# Use rpm-ostree's cliwrap to allow dracut to run on the container and generate
# an initramfs.
### COMMENT OUT BELOW LINE IF USING LOCALLY ###
rpm-ostree cliwrap install-to-root / && \
# Replace all installed kernel packages with the respective fsync packages
rpm-ostree override replace \
    $(echo $INSTALLED_KERNEL_PACKAGES | \
    sed -e 's/^/.\//' | \
    sed -e 's/ /-[0-9]*[^src].rpm .\//g' | \
    sed -e 's/$/-[0-9]*[^src].rpm/')

# Exit the directory
cd ..

# Cleanup
rm -r /tmp/kernel-fsync/
printf "### Kernel replaced, temp files cleaned up ###\n\n"
