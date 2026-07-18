{
  config,
  lib,
  ...
}:
let
  cfg = config.mariner.network;
in
{
  options.mariner.network = {
    address = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0.${toString config.mariner.cid}/24";
      defaultText = "Derived from `mariner.cid`";
      description = "Static IPv4 address assigned to the LAN interface.";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0.1";
      description = "Host static IPv4 address on the bridge.";
    };

    mac = lib.mkOption {
      type = lib.types.str;
      default = "02:00:00:00:00:${
        lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString config.mariner.cid))
      }";
      defaultText = "Derived from `mariner.cid`";
      description = "MAC address for the LAN interface.";
    };
  };

  config = {
    systemd.network.enable = true;

    networking.nftables.enable = true;

    microvm.interfaces = lib.mkDefault [
      {
        type = "tap";
        id = "microvm-${toString config.mariner.cid}";
        mac = config.mariner.network.mac;
      }
    ];

    systemd.network.networks."10-lan" = lib.mkDefault {
      matchConfig.MACAddress = cfg.mac;
      networkConfig = {
        Address = [ cfg.address ];
        Gateway = cfg.gateway;
        DNS = [ cfg.gateway ];
      };
    };
  };
}
