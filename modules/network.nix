{
  config,
  lib,
  ...
}:
{
  options.mariner.address = lib.mkOption {
    type = lib.types.str;
    default = "10.0.0.${toString config.mariner.cid}/24";
    defaultText = "Derived from `mariner.cid`";
    description = "Static IPv4 address assigned to the LAN interface.";
  };

  options.mariner.mac = lib.mkOption {
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
      mac = config.mariner.mac;
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
