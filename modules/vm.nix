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

  config = {
    networking.hostName = lib.mkDefault "vm";

    microvm.hypervisor = lib.mkDefault "qemu";

    microvm.vcpu = lib.mkDefault 4;
    microvm.mem = lib.mkDefault 4096;

    microvm.vsock.cid = config.mariner.cid;
  };
}
