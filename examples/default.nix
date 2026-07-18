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
  host = mkHost ./host.nix;
  vm = mkGuest ./vm.nix;
  ubuntu = mkGuest ./ubuntu.nix;
  android = mkGuest ./android.nix;
}
