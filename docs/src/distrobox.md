# Linux distributions userland (distrobox)

You can run other Linux distributions' userland inside the NixOS microVM, on the Docker backend. By default an Ubuntu box is configured, giving you an FHS environment where apt, .deb packages and systemctl just work. SSH drops you directly into the Ubuntu box.

Setting `mariner.distrobox.enable = true;` sets up ubuntu:24.04 with `autoEnter` configured:

```nix
nixosConfigurations.ubuntu = nixpkgs.lib.nixosSystem {
  inherit system;
  inherit specialArgs;
  modules = [
    {
      mariner.distrobox.enable = true;
      mariner.cid = 6;
      mariner.hostAuthorizedKey = "ssh-ed25519 AAAA... your@host";
    }
  ]
  ++ builtins.attrValues mariner.nixosModules;
};
```

## Configuration

The manifest options module is freeform. Besides the documented options, any key the distrobox assemble manifest supports passes through to the generated `distrobox.ini`.

For more information, see [Mariner options](./mariner-options.md) and [distrobox assemble manifest](https://github.com/89luca89/distrobox/blob/1.8.2.5/docs/usage/distrobox-assemble.md) 

```nix
mariner.distrobox.manifest.alpine = {
  image = "alpine:latest";
  additional_packages = [ "git" "curl" ];
  # any assemble key works too, e.g.:
  # start_now = true;
};
```

## Limitations

- **Networking**: The box is privileged but shares the VM's network namespace (`--network host`), so networking is the VM's responsibility, not the box's. Manage the firewall, ports, routes and DNS from the NixosConfiguration, not from inside the box.

- **Kernel**: The distrobox is sharing the VM's kernel. Kernel modules load on the VM-side. `modprobe` in the box can't work. If you need to add a module (e.g. a VPN's `tun`), enable it on the VM.

## What's declarative or mutable

The distrobox manifest is declarative: which boxes exist, their `image`, `hostname`, `additional_packages`, and the `autoEnter` and `replace` behavior in declared in NixOS Configuration are reproducible.

The box's filesystem is mutable: package installs and edits inside the box persist between reboots but are lost when the box is rebuilt. Same as the NixOS VM, `$HOME` and other storage volumes are persistent.

## First boot

The box is built at first boot, not at Nix build time, so the first start of a box needs network access:

- The `distrobox-assemble` service pulls the container image and creates the box, this might takes a while.
- If you SSH in before the box is ready, `autoEnter` finds no box and drops you into the NixOS shell with a "not found" message.
- On the first enter, distrobox installs base packages (plus your additional_packages) over the network.


## Shell modes

By default SSH `exec`s you into the box shell. To reach the VM's NixOS shell without turning off `autoEnter`:

```shell
ssh -t vm@<addr> 'bash --norc'   # NixOS shell (skips the autoEnter hook)
```
