{
  lib,
  pkgs,
  sourceInfo,
  ...
}:
let
  url =
    if sourceInfo.rev != null then
      "${sourceInfo.repo}/tree/${sourceInfo.rev}"
    else
      "${sourceInfo.repo}/tree/${sourceInfo.ref}";

  makeOptionsDoc =
    modules:
    pkgs.nixosOptionsDoc {
      inherit
        (
          (lib.evalModules {
            specialArgs = { inherit pkgs; };
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
      transformOptions =
        opt:
        opt
        // {
          declarations = map (
            decl:
            let
              root = toString ../.;
              declStr = toString decl;
              declPath = lib.removePrefix root decl;
            in
            if lib.hasPrefix root declStr then
              {
                name = declPath;
                url = "${url}${declPath}";
              }
            else
              decl
          ) opt.declarations;
        };
    };

  modulesOptionsDocs = makeOptionsDoc ([ ../modules ]);
  hostOptionsDocs = makeOptionsDoc ([ ../modules/host.nix ]);
in
pkgs.runCommand "nix-mariner-docs"
  {
    nativeBuildInputs = [ pkgs.mdbook ];
  }
  ''
    cp -Lr ${../docs} docs
    chmod u+w docs/src
    cp ${modulesOptionsDocs.optionsCommonMark} docs/src/mariner-options.md
    cp ${hostOptionsDocs.optionsCommonMark} docs/src/mariner-host-options.md
    mdbook build -d $out docs
  ''
