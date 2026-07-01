{
  config,
  lib,
  ...
}:
{
  options.mariner.address = lib.mkOption {
    type = lib.types.str;
    example = "10.0.0.2/24";
    description = "Static IPv4 address assigned to the LAN interface.";
  };

  config.systemd.network.enable = true;

  config.microvm.interfaces = lib.mkDefault [
    {
      type = "tap";
      id = "vm-${config.networking.hostName}";
      mac = "02:00:00:00:00:01";
    }
  ];

  config.systemd.network.networks."10-lan" = lib.mkDefault {
    matchConfig.Type = "ether";
    networkConfig = {
      Address = [ config.mariner.address ];
      Gateway = "10.0.0.1";
      DNS = [ "10.0.0.1" ];
    };
  };

}
