{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.microvm.url = "github:microvm-nix/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      microvm,
    }:
    let
      specialArgs = {
        inherit nixpkgs;
        hostAuthorizedKey = nixpkgs.lib.fileContents ./keys/host.pub;
      };
    in
    {
      nixosModules = {
        common = modules/common.nix;
        vm = modules/vm.nix;
        storage = modules/storage.nix;
        network = modules/network.nix;
        user = modules/user.nix;
        ssh = modules/ssh.nix;
        nix = modules/nix.nix;
      };
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          microvm.nixosModules.microvm
        ]
        ++ builtins.attrValues self.nixosModules;
      };
    };
}
