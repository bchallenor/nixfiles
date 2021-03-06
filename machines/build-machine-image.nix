{
  machineName,
  machineSize,
  nixpkgs ? <nixpkgs>
}:

let
  pkgs = import nixpkgs {};
  lib = import (nixpkgs + /lib);
  mkNixos = import (nixpkgs + /nixos);
  mkDiskImage = import (nixpkgs + /nixos/lib/make-disk-image.nix);

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

  machineConfig = (mkNixos {
    configuration = import (machineConfigDir + /configuration.nix);
  }).config;

  machineSystemHash = builtins.elemAt (
    builtins.match "/nix/store/([a-z0-9]+)-.*" machineConfig.system.build.toplevel.outPath
  ) 0;

  machineDiskImage = mkDiskImage {
    inherit lib pkgs;
    name = machineName;
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

  machineDiskImageFileName = "${machineName}-${machineSystemHash}.img";
in
  pkgs.linkFarm machineDiskImageFileName [{
    name = machineDiskImageFileName;
    path = machineDiskImage + /nixos.img;
  }]
