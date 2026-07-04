{
  lib,
  pkgs,
  modules,
  ...
}:
let
  makeOptionsDoc =
    modules:
    pkgs.nixosOptionsDoc {
      inherit
        (
          (lib.evalModules {
            modules = modules ++ [
              ({ lib, ... }: {
                config._module.check = false; # Skip NixOS module checks
                options._module.args = lib.mkOption {
                  internal = true; # Hide NixOS `_module.args` from nixosOptionsDoc
                };
              })
            ];
          })
        )
        options
        ;
    };

  optionDocs = makeOptionsDoc (builtins.attrValues modules);
in
pkgs.runCommand "nix-mariner-docs"
  {
    nativeBuildInputs = [ pkgs.mdbook ];
  }
  ''
    cp -Lr ${../docs} docs
    chmod u+w docs/src
    cp ${optionDocs.optionsCommonMark} docs/src/mariner-options.md
    mdbook build -d $out docs
  ''
