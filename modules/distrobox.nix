{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mariner.distrobox;
  distroboxManifestFormat = pkgs.formats.ini { listsAsDuplicateKeys = true; };
  distroboxManifestFile = distroboxManifestFormat.generate "distrobox.ini" cfg.manifest;

  distroboxManifestType = lib.types.submodule {
    freeformType = distroboxManifestFormat.type.nestedTypes.elemType;

    options.image = lib.mkOption {
      type = lib.types.str;
      description = "Which image should the distrobox container use";
    };

    options.init = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run systemd init as PID 1 inside distrobox";
    };

    options.entry = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Generate desktop entry. Must be false on headless distrobox";
    };
  };
in
{
  options.mariner.distrobox = {
    enable = lib.mkEnableOption "distrobox integration";

    manifest = lib.mkOption {
      type = lib.types.attrsOf distroboxManifestType;
      default = {
        ubuntu = {
          image = "ubuntu:24.04";
        };
      };
      description = ''
        Generates distrobox assemble manifest.ini, each attribute name is a `[section]` for a box.
        Freeform Option: you may add any key that assemble manifest supports. For the full list see: [distrobox-assemble manifest reference](https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-assemble.md).
      '';
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

      path = [
        config.virtualisation.docker.package
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.distrobox}/bin/distrobox assemble create --file ${distroboxManifestFile}";
      };
    };
  };
}
