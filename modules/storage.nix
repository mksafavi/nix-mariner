{
  config,
  lib,
  ...
}:
let
  vmUser = config.mariner.username;
in
{
  options.mariner.storage = {
    persistSizeMiB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8 * 1024;
      description = "Size of the /persist volume in MiB.";
    };

    nixStoreSizeMiB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 32 * 1024;
      description = "Size of the writable Nix store overlay in MiB.";
    };

    dockerSizeMiB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 32 * 1024;
      description = "Size of the docker volume in MiB.";
    };

    waydroidSizeMiB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 32 * 1024;
      description = "Size of the waydroid volume in MiB.";
    };
  };

  config = {
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    microvm.writableStoreOverlay = "/nix/.rw-store";

    microvm.shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];

    microvm.volumes = [
      {
        image = "persist.img";
        mountPoint = "/persist";
        size = config.mariner.storage.persistSizeMiB;
      }

      {
        image = "nix-store.img";
        mountPoint = "/nix/.rw-store";
        size = config.mariner.storage.nixStoreSizeMiB;
      }

      (lib.mkIf config.mariner.docker.enable {
        image = "docker.img";
        mountPoint = "/var/lib/docker";
        size = config.mariner.storage.dockerSizeMiB;
      })

      (lib.mkIf config.mariner.waydroid.enable {
        image = "waydroid.img";
        mountPoint = "/var/lib/waydroid";
        size = config.mariner.storage.waydroidSizeMiB;
      })
    ];

    fileSystems = {
      "/home" = {
        device = "/persist/home";
        options = [ "bind" ];
        fsType = "none";
        depends = [ "/persist" ];
      };

      "/nix/var" = {
        device = "/nix/.rw-store/var";
        options = [ "bind" ];
        fsType = "none";
        neededForBoot = true;
        depends = [ "/nix/.rw-store" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /persist/home 0755 root root -"
      "d /persist/home/${vmUser} 0700 ${vmUser} users -"
      "d /nix-store/var 0755 root root -"
      "d /persist/ssh 0755 root root -"
    ];
  };

}
