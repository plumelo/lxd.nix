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

  disks = mkOption {
    default = { };
    type = with types; attrsOf (submodule {
      options = {
        source = mkOption {
          type = types.str;
          description = lib.mdDoc ''
            Path on the host, either to a file/directory or to a block device
          '';
        };
        path = mkOption {
          type = types.str;
          description = lib.mdDoc ''
            Path inside the instance where the disk will be mounted (only for containers).
          '';
        };
        shift = mkOption {
          default = false;
          description = lib.mdDoc ''
            Setup a shifting overlay to translate the source uid/gid to match the instance (only for containers)
          '';
          type = types.bool;
        };
        options = mkOption {
          type = with types; attrs;
          description = lib.mdDoc ''
            Other options. See https://documentation.ubuntu.com/lxd/en/stable-4.0/instances/#type-disk
          '';
          default = {};
        };
      };
    });
    description = lib.mdDoc ''
      Disk devices.
    '';
  };

  config = mkOption {
    type = with types; nullOr attrs;
    description = lib.mdDoc ''
      LXD container configuration.
    '';
    default = null;
  };
}
