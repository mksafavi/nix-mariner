{
  config,
  lib,
  ...
}:
{
  options.mariner.cid = lib.mkOption {
    type = lib.types.ints.unsigned;
    description = "VSOCK context ID. Must be >= 3 and unique per host";
  };

  options.mariner.hostName = lib.mkOption {
    type = lib.types.str;
    default = config.mariner.username;
    description = "The name of the machine";
  };

  config = {
    networking.hostName = config.mariner.hostName;

    microvm.hypervisor = lib.mkDefault "qemu";

    microvm.vcpu = lib.mkDefault 4;
    microvm.mem = lib.mkDefault 4096;

    microvm.vsock.cid = config.mariner.cid;
  };
}
