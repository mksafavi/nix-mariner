{
  config,
  lib,
  ...
}:
let
  cfg = config.mariner.waydroid;
in
{
  options.mariner.waydroid = {
    enable = lib.mkEnableOption "waydroid integration";
  };

  config = lib.mkIf cfg.enable {

    virtualisation.waydroid.enable = true;
  };
}
