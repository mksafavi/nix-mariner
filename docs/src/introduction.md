# nix-mariner

NixOS microVM modules for creating development environments that isolate untrusted code from your host.

Built on [microvm.nix](https://github.com/microvm-nix/microvm.nix).

## What it does

- Provides NixOS modules importable as a flake input.
- Creates persistent microVM environments for isolating untrusted code away from the host.
- Preconfigured with SSH, Docker, direnv, shared `/nix/store`, persistent storage, bridge networking.
- Optional userlands inside the VM:
  - Ubuntu via [distrobox](distrobox.md), SSH logins directly into Ubuntu.
  - Android via [Waydroid](waydroid.md), opens a window on your host desktop.

## Imperative and Declarative workflows

The documentation covers both imperative and declarative workflows.
Before either, set up the host once: [Host setup](host-setup.md).

### Imperative
Creates VM with `microvm -c`. The only host NixOS changes are the one-time [Host setup](host-setup).

See [Imperative Virtual Machines](imperative-vms.md).

### Declarative
VMs defined inside the host's NixOS configurations with `microvm.vms.<name>`.

See [Declarative Virtual Machines](declarative-vms.md).

### Per-VM Customizations
You can change and override microvm.nix and nixos module configurations for each VM.
Overrides work the same in both imperative and declarative modes.

See [Customizing VMs](customization.md).


## Questions & Support

- Feel free to start a discussion on [Discussions](https://github.com/mksafavi/nix-mariner/discussions)
- Report bugs and feature requests at [Issues](https://github.com/mksafavi/nix-mariner/issues)
