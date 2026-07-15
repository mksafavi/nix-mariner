{
  config,
  lib,
  ...
}:
let
  cfg = config.mariner.docker;
in
{
  options.mariner.docker = {
    enable = lib.mkEnableOption "Docker integration";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
  };
}
