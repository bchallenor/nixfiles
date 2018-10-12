{ config, lib, pkgs, ... }:

let
  nixosConfigDir = "/etc/nixos";

  uid = 1000;
  gid = 1000;

  originUrl = "https://github.com/bchallenor/nixos-config.git";
  originPushUrl = "git@github.com:bchallenor/nixos-config.git";
in
{
  systemd.services.chown-nixos-config =
  {
    script = ''
      chown ${toString uid}:${toString gid} -R ${nixosConfigDir}
      chmod u=rwX,go=rX -R ${nixosConfigDir}
    '';
    serviceConfig = {
      Type = "oneshot";
      ProtectSystem = "strict";
      ReadWritePaths = nixosConfigDir;
    };
    unitConfig = {
      RequiresMountsFor = "${nixosConfigDir}";
    };
  };

  systemd.services.clone-nixos-config =
  {
    path = with pkgs; [ git ];
    script = ''
      git init
      git remote add origin ${originUrl}
      git remote set-url --push origin ${originPushUrl}
      git fetch origin
      git branch master origin/master
      git reset --mixed master
    '';
    serviceConfig = {
      Type = "oneshot";
      ProtectSystem = "strict";
      ReadWritePaths = nixosConfigDir;
      WorkingDirectory = nixosConfigDir;
      User = uid;
      Group = gid;
    };
    unitConfig = {
      ConditionPathIsDirectory = "!${nixosConfigDir}/.git";
    };
    after = [
      "chown-nixos-config.service"
      "network-online.target"
    ];
    requires = [
      "chown-nixos-config.service"
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];
  };
}
