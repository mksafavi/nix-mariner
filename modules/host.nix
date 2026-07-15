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

    systemd.user.services.mariner-waypipe-client = {
      description = "Start waypipe client";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
      };
      script = ''
        ${pkgs.waypipe}/bin/waypipe --vsock -s 2:6000 client
      '';
    };
  };
}
