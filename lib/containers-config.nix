{ modulesPath, config, pkgs, lib, ... }:
let
  containers = config.virtualisation.lxd.containers;
  package = config.virtualisation.lxd.package;
  configFormat = pkgs.formats.yaml { };
  mkService = { name, enable, auto, image, config, devices, profiles, ... }@cfg:
    let
      sys = (image.extendModules {
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
      instanceConf = {
        inherit config;
      }
      // (if devices == null then { } else { inherit devices; })
      // (if profiles == null then { } else { inherit profiles; });
    in
    rec {
      inherit enable;
      wantedBy = lib.optional cfg.auto "multi-user.target";
      path = [ package ] ++ (with pkgs; [ yq-go gnutar util-linux xz ]);
      script = ''
        root=$(find ${root} -name "*.tar.xz" -xtype f -print -quit)
        metadata=$(find ${metadata} -name "*.tar.xz" -xtype f -print -quit)
        fg=$(lxc image info play-image | yq '.Fingerprint')
        if lxc image import $metadata $root --alias ${name}-image; then
          lxc image delete $fg
          if lxc info ${name}; then
            lxc delete -f ${name}
          fi
          lxc launch ${name}-image ${name}
        fi
        lxc config show ${name} | yq '. *= load("${configFormat.generate "lxd-container-${name}-config.yaml" instanceConf}")' | lxc config edit ${name}
        lxc stop ${name}
        lxc start ${name}
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

  systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList
    (n: v:
      (lib.mapAttrsToList
        (n: v: "d ${v.source} 0770 root lxd")
        (lib.filterAttrs (n: v: v.type == "disk" && lib.hasPrefix "/var/lib/lxd/state" v.source) v.devices)
      )
    )
    containers
  );
}
