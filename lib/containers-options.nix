{ config
, lib
, ...
}@args:

with lib;

{
  enable = mkOption {
    default = true;
    description = lib.mdDoc ''
      Whether to enable the container.
    '';
    type = types.bool;
  };

  auto = mkOption {
    default = true;
    description = lib.mdDoc ''
      Whether to automatically apply changes to the container.
    '';
    type = types.bool;
  };

  container = mkOption {
    type = with types; attrs;
    description = lib.mdDoc ''
      A NixOS system. The result of a `nixpkgs.lib.nixosSystem` call.
    '';
    default = null;
  };

  config = mkOption {
    type = with types; nullOr attrs;
    description = lib.mdDoc ''
      LXD container configuration.
    '';
    default = null;
  };

  devices = mkOption {
    type = with types; nullOr attrs;
    description = lib.mdDoc ''
      All devices.
    '';
    default = null;
  };

  profiles = mkOption {
    type = with types; nullOr (listOf str);
    description = lib.mdDoc ''
      Profiles
    '';
    default = null;
  };

}
