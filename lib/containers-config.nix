{ modulesPath, config, pkgs, lib, ... }:
let
  containers = config.virtualisation.lxd.containers;
  package = config.virtualisation.lxd.package;
  configFormat = pkgs.formats.yaml { };
  mkService = { name, enable, auto, container, disks, config, ... }@cfg:
    let
      sys = (container.extendModules {
        modules = [
          "${modulesPath}/virtualisation/lxc-container.nix"
        ];
      });
      root = sys.config.system.build.tarball.override {
        compressCommand = "pixz -0 -t";
      };
      metadata = sys.config.system.build.metadata.override {
        compressCommand = "pixz -0 -t";
      };
      instanceConf = config // {
        devices = lib.concatMapAttrs
          (name: cfg@{ options, ... }: {
            "${name}" = (builtins.removeAttrs cfg [ "options" ]) // options // {
              type = "disk";
            };
          })
          disks;
      };
    in
    rec {
      inherit enable;
      wantedBy = lib.optional cfg.auto "multi-user.target";
      path = [ package ] ++ (with pkgs; [ yq-go gnutar util-linux xz ]);
      script = ''
        ${lib.concatLines (lib.mapAttrsToList (k: disk: "mkdir -p ${disk.source}") disks)}
        root=$(find ${root} -name "*.tar.xz" -xtype f -print -quit)
        metadata=$(find ${metadata} -name "*.tar.xz" -xtype f -print -quit)
        if lxc image import $metadata $root --alias ${name}-image; then
          if lxc info ${name}; then
            lxc delete -f ${name}
          fi
          lxc launch ${name}-image ${name}
        fi
        lxc config show ${name} | yq '. *= load("${configFormat.generate "lxd-container-${name}-config.yaml" instanceConf}")' | lxc config edit ${name}
      '';
      serviceConfig = {
        Type = "oneshot";
        Group = "lxd";
        RemainAfterExit = true;
      };
    };
in
{
  systemd.services = lib.concatMapAttrs
    (name: cfg: {
      "lxd-containers@${name}" = mkService (cfg // { inherit name; });
    })
    containers;
}
