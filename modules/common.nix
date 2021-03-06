{ config, lib, pkgs, ... }:

{
  imports = [
    ./clone-nixos-config.nix
    ./base-packages.nix
  ];

  boot.tmpOnTmpfs = true;

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    supportedLocales = [
      "en_GB.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  console = {
    packages = with pkgs; [
      terminus_font
    ];
    font = "ter-132n";
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
  system.nssModules = lib.mkForce [];

  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixpkgs-unstable=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  system.stateVersion = "19.09";
}
