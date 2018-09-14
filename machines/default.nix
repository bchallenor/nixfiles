let
  nixpkgs = <nixpkgs>;
  pkgs = import nixpkgs {};

  buildMachineImage = import ./build-machine-image.nix;

in {
  helios = buildMachineImage {
    inherit nixpkgs;
    machineName = "helios";
    machineSize = 2048;
  };

  jenkins = buildMachineImage {
    inherit nixpkgs;
    machineName = "jenkins";
    machineSize = 2048;
  };
}
