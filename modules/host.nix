{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mariner.host;
in
{
  options.mariner.host.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether to enable nix-mariner host module.
    '';
  };

  config = lib.mkIf cfg.enable {
    microvm.host.enable = true;
  };
}
