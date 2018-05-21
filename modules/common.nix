{ config, lib, pkgs, ... }:

{
  boot.cleanTmpDir = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  programs.bash.enableCompletion = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    permitRootLogin = "no";
  };

  programs.mosh.enable = true;

  services.nscd.enable = false;

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
