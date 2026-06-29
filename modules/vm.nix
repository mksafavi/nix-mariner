{ ... }:
{
  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-${config.networking.hostName}";
      mac = "02:00:00:00:00:01";
    }
  ];
}
