{
  config,
  ...
}:
{
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
