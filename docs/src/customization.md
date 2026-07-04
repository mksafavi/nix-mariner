# Per-VM Customizations

You can change and override microvm.nix and nixos module configurations for each VM.
Overrides work the same in both imperative and declarative modes.

For more information, see [Mariner options](./mariner-options.md) and [microvm.nix Options](https://microvm-nix.github.io/microvm.nix/microvm-options.html).

```nix
    vm = {
      specialArgs = { inherit nixpkgs; };
      config =
        { config, pkgs, ... }: # this points to the vm config to access config.mariner
        {
          imports = builtins.attrValues mariner.nixosModules ++ [ ];
          mariner.cid = 5;
          # Change user name:
          mariner.username = "user";
          mariner.hostAuthorizedKey = "ssh-ed25519 AAAA... your@host";
          # Set VM resources:
          microvm = {
            vcpu = 4;
            mem = 8 * 1024;
          };
          # Share a host directory with the VM:
          microvm.shares = [{
            source = "/home/you/work";
            mountPoint = "/work";
            tag = "work";
            proto = "virtiofs";
          }];

          # Install more packages:
          users.users.${config.mariner.username}.packages = with pkgs; [ btop ];
        };
    };
```
