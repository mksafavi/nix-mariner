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
      system = "x86_64-linux";
      specialArgs = {
        inherit nixpkgs;
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
        inherit system;
        inherit specialArgs;
        modules = [
          microvm.nixosModules.microvm
          {
            mariner.hostAuthorizedKey = nixpkgs.lib.fileContents ./keys/host.pub;
          }
        ]
        ++ builtins.attrValues self.nixosModules;
      };

      devShells.default =
        with import nixpkgs { inherit system; };
        mkShell {
          buildInputs = [
            nixfmt
            nixfmt-tree
            nix-fast-build
          ];
        };
    };
}
