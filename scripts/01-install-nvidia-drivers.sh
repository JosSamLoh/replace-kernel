#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia-cuda && \
sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
