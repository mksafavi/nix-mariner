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
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          microvm.nixosModules.microvm
          modules/common.nix
          modules/vm.nix
          modules/storage.nix
          modules/network.nix
          modules/user.nix
          modules/ssh.nix
        ];
      };
    };
}
