{ config, lib, pkgs, ... }:

# Used instead of services.redshift because:
# a) it assumes you want a provider, but we don't
# b) it does not let you specify a config file, but dawn/dusk time can only be set from a config file

let
  configFile = pkgs.writeText "redshift.conf" ''
    [redshift]
    temp-day=6500
    temp-night=3700
    dawn-time=07:00
    dusk-time=19:00
  '';
in
{
  environment.systemPackages = with pkgs; [ redshift ];

  systemd.user.services.redshift =
  {
    script = ''
      ${pkgs.redshift}/bin/redshift -c ${configFile}
    '';
    serviceConfig = {
      ProtectSystem = "strict";
      Restart = "always";
    };
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
  };
}
