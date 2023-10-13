{
  description = "Run NixOS containers with LXD.";
  inputs.nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, lib, pkgs, ... }@args: {
      options = import ./lib/options.nix args;
      config = import ./lib/config.nix args;
    };
  };
}
