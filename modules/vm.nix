{ config, ... }:
{

  microvm.hypervisor = "qemu";

  networking.hostName = "vm";

  systemd.network.enable = true;

  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-${config.networking.hostName}";
      mac = "02:00:00:00:00:01";
    }
  ];

  systemd.network.networks."10-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      Address = [ "10.0.0.2/24" ];
      Gateway = "10.0.0.1";
      DNS = [ "10.0.0.1" ];
    };
  };

  microvm = {
    vcpu = 4;
    mem = 4096;
  };

  microvm.vsock.cid = 3;

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
      image = "/var/lib/microvms/${config.networking.hostName}/persist.img";
      mountPoint = "/persist";
      size = 8 * 1024;
    }
    {
      image = "/var/lib/microvms/${config.networking.hostName}/nix-store.img";
      mountPoint = "/nix/.rw-store";
      size = 32 * 1024;
    }
  ];

  fileSystems = {
    "/home" = {
      device = "/persist/home";
      options = [ "bind" ];
      fsType = "none";
    };
    "/var/lib/docker" = {
      device = "/persist/var/lib/docker";
      options = [ "bind" ];
      fsType = "none";
    };
  };

  systemd.tmpfiles.rules = [
    "d /persist/home 0755 root root -"
    "d /persist/home/vm 0700 vm users -"
    "d /persist/var/lib/docker 0710 root root -"
    "d /persist/ssh 0755 root root -"
  ];

}
