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
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosModules = {
        default = {
          imports = [
            ./modules
            microvm.nixosModules.microvm
          ];
        };
        host = {
          imports = [
            ./modules/host.nix
            microvm.nixosModules.host
          ];
        };
      };

      nixosConfigurations = import ./examples { inherit self nixpkgs system; };

      packages.${system}.docs = pkgs.callPackage ./pkgs/docs.nix {
        sourceInfo = {
          repo = "https://github.com/mksafavi/nix-mariner";
          rev = self.rev or null;
          ref = self.ref or "main";
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixfmt
          nixfmt-tree
          nix-fast-build
          mdbook
          deadnix
        ];
      };

      checks.${system} =
        let
          systemsAttrs = nixpkgs.lib.mapAttrs' (
            n: c:
            if c.config.microvm ? runner then
              nixpkgs.lib.nameValuePair "microvm-${n}" c.config.microvm.runner.qemu
            else
              nixpkgs.lib.nameValuePair "host-${n}" c.config.system.build.toplevel
          ) self.nixosConfigurations;
          devShellsAttrs = nixpkgs.lib.mapAttrs' (
            n: nixpkgs.lib.nameValuePair "devShell-${n}"
          ) self.devShells.${system};
          docsAttrs = {
            "docs" = self.packages.${system}.docs;
          };
        in
        (systemsAttrs // devShellsAttrs // docsAttrs);
    };
}
