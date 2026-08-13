# Storage and persistence

The root filesystem (`/`) and `/tmp` are `tmpfs` mounts that are wiped on every reboot. Anything you want to keep should be kept on a persitent volume like `$HOME`.
Some modules provide persistent volumes and store them on the host as QEMU images under `/var/lib/microvms/<name>/<image>.img`

See [options reference](./mariner-options.md) for the available volumes and sizes.

## Nix store share

The host's `/nix/store` is shared into the guest as a read-only filesystem, with a writable overlay on top of it.
Set `mariner.storage.readOnlyStoreShare` to select the protocol for sharing the host's store or set it to `null` if you don't want to share the store.

## Volume sizes

Volume images are sparse: a volume with an apparent size of 32GB only allocates the space that's actually used.
The allocated size will grow over time as you create and delete files, but a scheduled `fstrim.service` in the VM reclaims the freed blocks back to the host.

The size is only applied when the image is first created. Changing a `SizeMiB` option later doesn't resize the volume.

```shell
$ du -hs --apparent-size  /var/lib/microvms/vm/*
32G     /var/lib/microvms/vm/nix-store.img
8.0G    /var/lib/microvms/vm/persist.img

$ du -hs  /var/lib/microvms/vm/*
1.4G    /var/lib/microvms/vm/nix-store.img
613M    /var/lib/microvms/vm/persist.img
```

## Resizing a volume
You can resize the volumes after they are created.
Make sure to **stop** the virtual machine before doing filesystem operations otherwise you will corrupt the volume and lose data.
It's recommended to only **grow** the images. For shrinking you have to first shrink the file system size before running `qemu-img resize`

```shell
sudo systemctl stop microvm@<name>.service

sudo qemu-img resize --format raw /var/lib/microvms/<name>/<image>.img <new-size>
sudo e2fsck -f /var/lib/microvms/<name>/<image>.img
sudo resize2fs /var/lib/microvms/<name>/<image>.img

sudo systemctl start microvm@<name>.service
```

Resizing persist volume to 64GB:
```shell
sudo systemctl stop microvm@vm.service

sudo qemu-img resize --format raw /var/lib/microvms/vm/persist.img 64G
sudo e2fsck -f /var/lib/microvms/vm/persist.img
sudo resize2fs /var/lib/microvms/vm/persist.img

sudo systemctl start microvm@vm.service
```

## Clearing a VM

To clear a VM's state, remove the appropriate image files in `/var/lib/microvms/<name>/`.

- `persist.img`: $HOME and user data
- `nix-store.img`: the writable store overlay
- `docker.img`: the docker volume (only if `mariner.docker.enable` is set)
- `waydroid.img`: the waydroid volume (only if `mariner.waydroid.enable` is set)

```shell
sudo systemctl stop microvm@<name>.service
sudo rm /var/lib/microvms/<name>/*.img
```

