# Declarative Virtual Machines

You can declare virtual machines directly in the host's NixOS configurations by adding `microvm.vms.<name>` entries in a module.

`nixos-rebuild switch` then builds, updates, and starts them via systemd.
You can't modify VMs with `microvm` CLI anymore if you use the declarative workflow.

See [`Declarative MicroVMs`](https://microvm-nix.github.io/microvm.nix/declarative.html)
for the upstream option reference.

## Declare Multiple Virtual Machines

> [!NOTE]
> Before continuing, make sure you've completed the [Host Setup](host-setup.md).

Create a `virtualization.nix` module and import it into your host setup:
```nix
{
  config,
  pkgs,
  mariner,
  nixpkgs,
  ...
}:
{
  microvm.vms = {
    vm-work = {
      specialArgs = { inherit nixpkgs; };
      config =
        { config, pkgs, ... }: # this points to the vm config to access config.mariner
        {
          imports = builtins.attrValues mariner.nixosModules ++ [ ];
          mariner.cid = 4;
          mariner.username = "work";
          mariner.hostAuthorizedKey = "ssh-ed25519 AAAA... your@host";
        };
    };

    vm-test = {
      specialArgs = { inherit nixpkgs; };
      config =
        { config, pkgs, ... }: # this points to the vm config to access config.mariner
        {
          imports = builtins.attrValues mariner.nixosModules ++ [ ];
          mariner.cid = 5;
          mariner.username = "user";
          mariner.hostAuthorizedKey = "ssh-ed25519 AAAA... your@host";
        };
    };
  };
}
```

Import the modules into your host configurations:
```nix
# In another module:
  imports = [
    modules/virtualization.nix
  ];
```
```nix
# Or in host flake:
  nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
    #...
    modules = [
      modules/virtualization.nix
      # ...
    ];
  };
```

`nixos-rebuild switch` should build each VM and start the systemd services `microvm@<name>.service`

Now you can ssh into them if the services are running:
```shell
ssh work@vsock%4
ssh user@vsock%5
```

See `microvm.autostart` for starting the VMs automatically at host boot.
