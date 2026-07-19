{
  self,
  nixpkgs,
  system,
  ...
}:
let
  mkSystem =
    modules:
    nixpkgs.lib.nixosSystem {
      inherit system modules;
    };
  mkHost =
    module:
    mkSystem [
      self.nixosModules.host
      module
    ];
  mkGuest =
    module:
    mkSystem [
      self.nixosModules.default
      module
    ];
in
{
  example-host = mkHost ./host.nix;
  example-vm = mkGuest ./vm.nix;
  example-ubuntu = mkGuest ./ubuntu.nix;
  example-android = mkGuest ./android.nix;
}
