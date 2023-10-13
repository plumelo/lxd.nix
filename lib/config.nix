{ config, lib, ... }@args:
let cfg = config.virtualisation.lxd;
in lib.mkIf cfg.enable (lib.mkMerge [
  {  }
  (import ./containers-config.nix args)
])
