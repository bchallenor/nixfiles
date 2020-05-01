{ config, lib, pkgs, ... }:

{
  fileSystems."/var/lib/gitea" =
    { device = "/dev/vg/gitea";
      fsType = "ext4";
    };

  services.gitea = {
    enable = true;

    stateDir = "/var/lib/gitea";

    domain = "localhost";
    rootUrl = "http://localhost:3000/";
    httpAddress = "127.0.0.1";
    httpPort = 3000;

    database = {
      type = "sqlite3";
    };

    disableRegistration = true;

    dump = {
      enable = true;
      interval = "daily";
    };
  };
}
