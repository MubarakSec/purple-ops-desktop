# Purple Ops system-theme rollback

Original state:

- Plymouth alternative: `/usr/share/plymouth/themes/bgrt/bgrt.plymouth`
- GDM custom appearance file: absent

Rollback:

```bash
sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/bgrt/bgrt.plymouth
sudo update-initramfs -u
sudo rm /usr/share/gdm/dconf/90-purple-ops
sudo /usr/share/gdm/generate-config
```

The source files remain under `~/.local/share/purple-ops/`.
