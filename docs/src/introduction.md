# nix-mariner

NixOS microVM modules for sandboxing untrusted development work.

Built on [microvm.nix](https://github.com/microvm-nix/microvm.nix).

## What it does

- Sandboxes untrusted code away from the host.
- Provides NixOS modules importable as a flake input.
- Preconfigured: SSH, Docker, direnv, shared `/nix/store`, persistent storage, bridge networking, etc.
