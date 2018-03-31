{
  machineName,
  machineSize
}:
let
  nixos = import <nixpkgs/nixos> {
    configuration = { config, lib, pkgs, ... }:
    let
      machineConfigDir = pkgs.stdenv.mkDerivation {
        name = "${machineName}-config-dir";
        src = fetchGit {
          url = ../.;
        };
        buildPhase = ''
          ln -s machines/${machineName}/configuration.nix configuration.nix
        '';
        installPhase = ''
          cp -R . $out
        '';
      };

      machineConfig = (import <nixpkgs/nixos> {
        configuration = import (machineConfigDir + /configuration.nix);
      }).config;
    in
    {
      config.system.build.diskImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
        inherit lib pkgs;
        name = "${machineName}-${machineConfigDir.src.shortRev}-disk-image";
        config = machineConfig;
        contents = [
          # rsync needs trailing slash
          { source = "${machineConfigDir}/"; target = "/etc/nixos"; }
        ];
        diskSize = machineSize;
        partitionTableType = "legacy";
        fsType = "ext4";
        format = "raw";
      };
    };
  };
in
  nixos.config.system.build.diskImage
