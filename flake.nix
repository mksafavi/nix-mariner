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
          nix-tree
        ];
      };

      checks.${system} =
        let
          hypervisors = nixpkgs.lib.filter (hv: hv != "vfkit") microvm.lib.hypervisors;
          guests = nixpkgs.lib.filterAttrs (_: c: c.config.microvm ? runner) self.nixosConfigurations;
          headlessGuests = nixpkgs.lib.filterAttrs (_: c: !c.config.microvm.graphics.enable) guests;
          guestsForHypervisor = hv: if hv == "qemu" then guests else headlessGuests;
          hosts = nixpkgs.lib.filterAttrs (_: c: !(c.config.microvm ? runner)) self.nixosConfigurations;

          guestsAttrs = nixpkgs.lib.mergeAttrsList (
            nixpkgs.lib.map (
              hv:
              nixpkgs.lib.mapAttrs' (
                n: c:
                nixpkgs.lib.nameValuePair "microvm-${hv}-${n}"
                  (c.extendModules {
                    modules = [
                      {
                        microvm.hypervisor = hv;
                      }
                    ];
                  }).config.microvm.declaredRunner
              ) (guestsForHypervisor hv)
            ) hypervisors
          );

          hostsAttrs = nixpkgs.lib.mapAttrs' (
            n: c: nixpkgs.lib.nameValuePair "host-${n}" c.config.system.build.toplevel
          ) hosts;

          devShellsAttrs = nixpkgs.lib.mapAttrs' (
            n: nixpkgs.lib.nameValuePair "devShell-${n}"
          ) self.devShells.${system};

          docsAttrs = {
            "docs" = self.packages.${system}.docs;
          };
        in
        (guestsAttrs // hostsAttrs // devShellsAttrs // docsAttrs);
    };
}
