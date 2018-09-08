let
  nixpkgs = <nixpkgs>;
  pkgs = import nixpkgs {};

  buildMachineImage = import ./build-machine-image.nix;

  images = [
    (buildMachineImage {
      inherit nixpkgs;
      machineName = "eos";
      machineSize = 2048;
    })
    (buildMachineImage {
      inherit nixpkgs;
      machineName = "helios";
      machineSize = 2048;
    })
    (buildMachineImage {
      inherit nixpkgs;
      machineName = "nyx";
      machineSize = 2048;
    })
  ];

in
  pkgs.symlinkJoin {
    name = "images";
    paths = images;
  }
