{
  config,
  lib,
  ...
}:
{

  systemd.network.enable = true;

  microvm.interfaces = lib.mkDefault [
    {
      type = "tap";
      id = "vm-${config.networking.hostName}";
      mac = "02:00:00:00:00:01";
    }
  ];

  systemd.network.networks."10-lan" = lib.mkDefault {
    matchConfig.Type = "ether";
    networkConfig = {
      Address = [ "10.0.0.2/24" ];
      Gateway = "10.0.0.1";
      DNS = [ "10.0.0.1" ];
    };
  };

}
