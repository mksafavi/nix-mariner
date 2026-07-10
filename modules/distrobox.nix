{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mariner.distrobox = {
    enable = lib.mkEnableOption "distrobox integration";
  };

  config = lib.mkIf config.mariner.distrobox.enable {

    environment.systemPackages = with pkgs; [
      distrobox
    ];

  };
}
