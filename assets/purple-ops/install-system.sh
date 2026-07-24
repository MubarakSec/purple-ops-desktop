#!/usr/bin/env bash
set -euo pipefail

source_root="__HOME__/.local/share/purple-ops"
plymouth_target="/usr/share/plymouth/themes/purple-ops"
brand_target="/usr/local/share/purple-ops"

install -d -m 0755 "$plymouth_target"
cp -a /usr/share/plymouth/themes/spinner/. "$plymouth_target/"
install -m 0644 "$source_root/plymouth/purple-ops.plymouth" \
  "$plymouth_target/purple-ops.plymouth"
install -m 0644 "$source_root/plymouth/watermark.png" \
  "$plymouth_target/watermark.png"

install -d -m 0755 "$brand_target"
install -m 0644 "$source_root/brand/purple-ops-mark.svg" \
  "$brand_target/purple-ops-mark.svg"

install -m 0644 "$source_root/gdm/90-purple-ops" \
  /usr/share/gdm/dconf/90-purple-ops
/usr/share/gdm/generate-config

update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth \
  default.plymouth \
  "$plymouth_target/purple-ops.plymouth" \
  150
update-alternatives --set \
  default.plymouth \
  "$plymouth_target/purple-ops.plymouth"
update-initramfs -u
