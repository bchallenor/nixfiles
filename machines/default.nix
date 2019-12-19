let
  nixpkgs = <nixpkgs>;
  pkgs = import nixpkgs {};

  buildMachineImage = import ./build-machine-image.nix;

in {
  chaos = buildMachineImage {
    inherit nixpkgs;
    machineName = "chaos";
    machineSize = 2048;
  };

  helios = buildMachineImage {
    inherit nixpkgs;
    machineName = "helios";
    machineSize = 3072;
  };

  aegis = buildMachineImage {
    inherit nixpkgs;
    machineName = "aegis";
    machineSize = 2048;
  };

  nat = buildMachineImage {
    inherit nixpkgs;
    machineName = "nat";
    machineSize = 2048;
  };

  jenkins = buildMachineImage {
    inherit nixpkgs;
    machineName = "jenkins";
    machineSize = 3072;
  };
}
