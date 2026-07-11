# Caveats

## Don't run `nix-collect-garbage` inside a VM

A microVM mounts the host's `/nix/store` as read-only (`/nix/.ro-store`) and layers a writable overlay on top.
Running `nix-collect-garbage` **inside the VM** cannot delete anything from the read-only base, instead it records
[*whiteout*](https://www.kernel.org/doc/html/latest/filesystems/overlayfs.html#whiteouts-and-opaque-directories)
deletions in the writable overlay.

So from the VM's perspective every path in `/nix/.ro-store` can be marked deleted, while the host store stays untouched. The downside of this is that you lose the shared store paths but the VM should still operate correctly.

`nix-collect-garbage` will whiteout delete every unreferenced paths from the read-only store:
```shell
[vm@nixos:~]$ nix-collect-garbage --dry-run
finding garbage collector roots...
determining live/dead paths...
123791 store paths would be deleted
```

The running VM system is protected, because `/nix/var` is mounted early and its closure is registered as a valid GC root.

**Recovery**:
If you ran `nix-collect-garbage` and lost access to the read-only store you can recover it by deleting the writable store overlay volume image (`/var/lib/microvms/<name>/nix-store.img`) and restarting the VM. The read-only host store will show up cleanly again. Your data/persist volumes are separate and aren't affected.
