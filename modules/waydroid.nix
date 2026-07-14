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

    systemImage = lib.mkOption {
      type = lib.types.enum [
        "VANILLA"
        "GAPPS"
        "FOSS"
      ];
      default = "VANILLA";
      description = ''
        Set Android system image variant
      '';
    };
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
        ${pkgs.waydroid}/bin/waydroid init -s ${cfg.systemImage}
      '';
    };

    systemd.services.waydroid-session-start = {
      description = "start waydroid session inside a waypipe server";
      wantedBy = [ "multi-user.target" ];
      after = [
        "waydroid-init.service"
        "waydroid-container.service"
      ];
      requires = [
        "waydroid-init.service"
        "waydroid-container.service"
      ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
        User = config.mariner.username;
      };
      environment = {
        XDG_RUNTIME_DIR = "/run/user/${lib.toString config.users.users.${config.mariner.username}.uid}";
      };
      preStart = ''
        # Hack to ignore missing PulseAudio
        mkdir -p $XDG_RUNTIME_DIR/pulse
        ln -sf /dev/null $XDG_RUNTIME_DIR/pulse/native
      '';
      script = ''
        ${pkgs.waypipe}/bin/waypipe --vsock -s 2:6000 server \
        ${pkgs.waydroid}/bin/waydroid session start
      '';
    };
  };
}
