{ config, ... }:
{
  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-${config.networking.hostName}";
      mac = "02:00:00:00:00:01";
    }
  ];

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
}
