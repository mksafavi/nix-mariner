# Caveats

## Don't run `nix-collect-garbage` inside a VM

A microVM mounts the host's `/nix/store` as read-only (`/nix/.ro-store`) and layers a writable overlay on top.
Running `nix-collect-garbage` **inside the VM** cannot delete anything from the read-only base, instead it records
[*whiteout*](https://www.kernel.org/doc/html/latest/filesystems/overlayfs.html#whiteouts-and-opaque-directories)
deletions in the writable overlay.

So from the VM's perspective every path in `/nix/.ro-store` can be marked deleted, while the host store stays untouched.

The VM's GC roots point at the running system, but its store path isn't registered as valid in VM's Nix DB, so `nix-collect-garbage` reports them as `invalid roots` and skips them:
```shell
[vm@nixos:~]$ nix-collect-garbage --dry-run
finding garbage collector roots...
skipping invalid root from "/run/booted-system" to "/nix/store/fr60nzah3ffmrvg612kw6i3harrakrrg-nixos-system-nixos-26.11.20260626.e73de5b"
skipping invalid root from "/run/current-system" to "/nix/store/fr60nzah3ffmrvg612kw6i3harrakrrg-nixos-system-nixos-26.11.20260626.e73de5b"
determining live/dead paths...
123791 store paths would be deleted
```
So GC deletes the running system's closure and the VM won't bookt afterwards(`systemd[1]: Unit default.target not found`).

**Recovery**:

delete the writable store overlay volume image (`/var/lib/microvms/<name>/nix-store.img`) and restart the VM.
The read-only host store shows through cleanly again. Your data/persist volumes are separate and aren't affected.
