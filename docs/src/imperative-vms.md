# Imperative Virtual Machines

In the imperative workflow, you define virtual machines under `nixosConfigurations.<vm>` in a flake, then use the `microvm` CLI to manage their lifecycle. See [`Imperative MicroVMs`](https://microvm-nix.github.io/microvm.nix/microvm-command.html) for the upstream option reference.

## Define a Virtual Machine in a Flake

> [!NOTE]
> Before continuing, make sure you've completed the [Host Setup](host-setup.md).

Add `nix-mariner` as a flake input, then define a `nixosConfigurations.<vm>` entry for your virtual machine.

The following `flake.nix` creates a VM named `example`:
```nix
{
  inputs.mariner.url = "github:mksafavi/nix-mariner";

  outputs =
    { self, mariner }:
    let
      nixpkgs = mariner.inputs.nixpkgs;
    in
    {
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixpkgs; };
        modules = builtins.attrValues mariner.nixosModules ++ [
          {
            mariner.cid = 4; # Unique per-VM CID that sets vsock number and IP address.
            mariner.hostAuthorizedKey = "ssh-ed25519 AAAA... your@host"; # Replace with your ssh public key
          }
        ];
      };
    };
}
```

Calling `microvm -c` builds the VM and creates the systemd service for booting it.

```shell
sudo microvm -c example -f path:$(pwd)
```

Verify that the vm is created:
```shell
microvm -l
```

Either start the service:
```shell
sudo systemctl start microvm@example.service
```

Or start it in foreground:
```shell
sudo microvm -r example
```

You can now ssh into it:
```shell
ssh vm@vsock%4
# or:
ssh vm@10.0.0.4
```

See [`examples/flake.nix`](https://github.com/mksafavi/nix-mariner/blob/main/examples/flake.nix) for a standalone flake example.
