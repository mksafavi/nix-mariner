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
    microvm = {
      hypervisor = lib.mkDefault "qemu";

      vcpu = lib.mkDefault 4;
      mem = lib.mkDefault 4096;

      vsock.cid = config.mariner.cid;

      balloon = lib.mkDefault (
        lib.elem config.microvm.hypervisor [
          "qemu"
          "cloud-hypervisor"
          "crosvm"
        ]
      );
    };

    boot.tmp = lib.mkDefault {
      useTmpfs = true;
      tmpfsSize = "80%";
    };
  };
}
