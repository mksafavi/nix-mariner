{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mariner.distrobox;
  settingsFormat = pkgs.formats.ini { listsAsDuplicateKeys = true; };
  settingsFile = settingsFormat.generate "distrobox.ini" cfg.settings;
in
{
  options.mariner.distrobox = {
    enable = lib.mkEnableOption "distrobox integration";

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = "Configuration for distrobox manifest";
    };
  };

  config = lib.mkIf config.mariner.distrobox.enable {

    environment.systemPackages = with pkgs; [
      distrobox
    ];

    systemd.services.distrobox-assemble = {
      description = "distrobox assemble service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "docker.service"
      ];
      wants = [
        "network-online.target"
      ];
      requires = [
        "docker.service"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.distrobox}/bin/distrobox assemble create --file ${settingsFile}";
      };
    };
  };
}
