{
  config,
  lib,
  ...
}:
{
  options.mariner.network.address = lib.mkOption {
    type = lib.types.str;
    default = "10.0.0.${toString config.mariner.cid}/24";
    defaultText = "Derived from `mariner.cid`";
    description = "Static IPv4 address assigned to the LAN interface.";
  };

  options.mariner.network.mac = lib.mkOption {
    type = lib.types.str;
    default = "02:00:00:00:00:${
      lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString config.mariner.cid))
    }";
    defaultText = "Derived from `mariner.cid`";
    description = "MAC address for the LAN interface.";
  };

  config.systemd.network.enable = true;

  config.networking.nftables.enable = true;

  config.microvm.interfaces = lib.mkDefault [
    {
      type = "tap";
      id = "microvm-${toString config.mariner.cid}";
      mac = config.mariner.network.mac;
    }
  ];

  config.systemd.network.networks."10-lan" = lib.mkDefault {
    matchConfig.MACAddress = config.mariner.network.mac;
    networkConfig = {
      Address = [ config.mariner.network.address ];
      Gateway = "10.0.0.1";
      DNS = [ "10.0.0.1" ];
    };
  };

}
