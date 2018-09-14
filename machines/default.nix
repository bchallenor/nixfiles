let
  nixpkgs = <nixpkgs>;
  pkgs = import nixpkgs {};

  buildMachineImage = import ./build-machine-image.nix;

in {
  eos = buildMachineImage {
    inherit nixpkgs;
    machineName = "eos";
    machineSize = 2048;
  };

  helios = buildMachineImage {
    inherit nixpkgs;
    machineName = "helios";
    machineSize = 2048;
  };

  nyx = buildMachineImage {
    inherit nixpkgs;
    machineName = "nyx";
    machineSize = 2048;
  };

  jenkins = buildMachineImage {
    inherit nixpkgs;
    machineName = "jenkins";
    machineSize = 2048;
  };
}
