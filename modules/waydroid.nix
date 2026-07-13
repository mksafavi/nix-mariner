{
  config,
  lib,
  pkgs,
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

    systemd.services.waydroid-init = {
      description = "initialize waydroid";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
      ];
      wants = [
        "network-online.target"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${pkgs.waydroid}/bin/waydroid init
      '';
    };
  };
}
