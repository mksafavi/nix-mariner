{
  config,
  lib,
  ...
}:
let
  cfg = config.mariner.graphics;
in
{
  options.mariner.graphics = {
    enable = lib.mkEnableOption "Graphical desktop apps support";
  };

  config = lib.mkIf cfg.enable {

    hardware.graphics.enable = true;

    microvm.graphics = {
      enable = true;
    };
  };
}
