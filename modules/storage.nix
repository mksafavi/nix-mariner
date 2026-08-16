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
    readOnlyStoreShare = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "virtiofs"
          "9p"
        ]
      );
      default = null;
      description = ''
        Sets the protocol for sharing the host machine /nix/store as a read-only share. setting it to `null` disables it.
        Check the `microvm.hypervisor` supported protocols before setting this option.

        `virtiofs` performs better than `9p` and requires `microvm-virtiofsd@<name>.service` to run on the host besides the VM
        which is automatically started as a dependency of `microvm@<name>.service`.
      '';
    };

    persistSizeMiB = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = 32 * 1024;
      description = ''
        Size of the /persist volume in MiB.
        Holds the user's `$HOME` and anything written under `/persist` in the VM.
      '';
    };

    nixStoreSizeMiB = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = ''
        Size of the writable Nix store overlay in MiB.
        A writable overlay on the read-only host nix store, caches nix-shell and flake outputs built inside the VM.
      '';
    };

    dockerSizeMiB = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = if config.mariner.docker.enable then 32 * 1024 else null;
      description = ''
        Size of the docker volume in MiB.
        Stores Docker containers, images and volumes. Only created when `mariner.docker.enable` is set.
      '';
    };

    waydroidSizeMiB = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = if config.mariner.waydroid.enable then 32 * 1024 else null;
      description = ''
        Size of the waydroid volume in MiB.
        Holds the Android system/vendor images and Waydroid configurations.
      '';
    };
  };

  config = {
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    microvm.writableStoreOverlay = "/nix/.rw-store";

    microvm.shares = lib.optional (config.mariner.storage.readOnlyStoreShare != null) {
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      proto = config.mariner.storage.readOnlyStoreShare;
      readOnly = true;
    };

    microvm.volumes =
      (lib.optional (config.mariner.storage.persistSizeMiB != null) {
        image = "persist.img";
        mountPoint = "/persist";
        size = config.mariner.storage.persistSizeMiB;
      })
      ++ (lib.optional (config.mariner.storage.nixStoreSizeMiB != null) {
        image = "nix-store.img";
        mountPoint = "/nix/.rw-store";
        size = config.mariner.storage.nixStoreSizeMiB;
      })
      ++ (lib.optional (config.mariner.storage.dockerSizeMiB != null) {
        image = "docker.img";
        mountPoint = "/var/lib/docker";
        size = config.mariner.storage.dockerSizeMiB;
      })
      ++ (lib.optional (config.mariner.storage.waydroidSizeMiB != null) {
        image = "waydroid.img";
        mountPoint = "/var/lib/waydroid";
        size = config.mariner.storage.waydroidSizeMiB;
      });

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
