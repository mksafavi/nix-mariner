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

  distroboxManifestType = lib.types.submodule (
    { name, ... }: {
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

      options.hostname = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "distrobox host name";
      };

      options.additional_packages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "git"
          "curl"
          "vim"
        ];
        description = "Extra packages to install in the box";
      };
    }
  );
in
{
  options.mariner.distrobox = {
    enable = lib.mkEnableOption "distrobox integration";

    autoEnter = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "ubuntu";
      description = "Automatically enter distrobox on interactive login";
    };

    replace = lib.mkOption {
      type = lib.types.enum [
        "onChange"
        "never"
        "always"
      ];
      default = "onChange";
      description = ''
        Whether to recreate boxes.
        `always` on every boot, `never` only manually with `distrobox assemble create --replace` or `onChange` when the manifest file changes
      '';
    };

    manifest = lib.mkOption {
      type = lib.types.attrsOf distroboxManifestType;
      default = {
        ubuntu = {
          image = "ubuntu:24.04";
        };
      };
      description = ''
        Generates distrobox assemble manifest.ini, each attribute name is a `[section]` for a box.
        Freeform Option: you may add any key that assemble manifest supports.
        For the full list see: [distrobox-assemble manifest reference](https://github.com/89luca89/distrobox/blob/1.8.2.5/docs/usage/distrobox-assemble.md).
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    mariner.docker.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      distrobox
    ];

    services.openssh.settings.AcceptEnv = lib.mkIf (cfg.autoEnter != null) [ "MARINER_NO_AUTOENTER" ];

    programs.bash.interactiveShellInit = lib.mkIf (cfg.autoEnter != null) (
      lib.mkAfter ''
        if [ -z "$CONTAINER_ID" ] && [ -z "$MARINER_NO_AUTOENTER" ]; then
          if ${config.virtualisation.docker.package}/bin/docker container inspect ${cfg.autoEnter} >/dev/null 2>&1; then
            exec ${pkgs.distrobox}/bin/distrobox enter --no-workdir ${cfg.autoEnter}
          else
            echo "distrobox '${cfg.autoEnter}' not found, staying in the NixOS shell."
            echo "Check: systemctl status distrobox-assemble"
          fi
        fi
      ''
    );

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
        Restart = "on-failure";
        RestartSec = "10s";
        User = config.mariner.username;
      };
      script =
        let
          assemble = "${pkgs.distrobox}/bin/distrobox assemble create --file ${distroboxManifestFile}";
        in
        if cfg.replace == "onChange" then
          ''
            state="$HOME/.applied-manifest"
            applied_manifest=$(cat "$state" 2>/dev/null || true)
            if [ "$applied_manifest" = "${distroboxManifestFile}" ]; then
              ${assemble}
            else
              ${assemble} --replace
              echo "${distroboxManifestFile}" > "$state"
            fi
          ''
        else if cfg.replace == "always" then
          ''
            ${assemble} --replace
          ''
        else
          ''
            ${assemble}
          '';
    };
  };
}
