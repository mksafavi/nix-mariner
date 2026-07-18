{ ... }: {
  mariner.distrobox.manifest.alpine = {
    image = "alpine:latest";
    additional_packages = [
      "git"
      "curl"
    ];
    # any assemble key works too, e.g.:
    # start_now = true;
  };
}
