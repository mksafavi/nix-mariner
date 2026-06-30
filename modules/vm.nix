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
}
