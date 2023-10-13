{ config
, lib
, ...
}@args:

with lib;

{
  virtualisation.lxd = {
    containers = mkOption {
      default = { };
      type = with types; attrsOf (submodule {
        options = import ./containers-options.nix args;
      });
      description = lib.mdDoc ''
        Multiple containers.
      '';
    };
  };
}
