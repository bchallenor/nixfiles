{ config, lib, pkgs, ... }:

{
  imports = [
    ./clone-nixos-config.nix
    ./overlays.nix
  ];

  boot.tmpOnTmpfs = true;

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    supportedLocales = [
      "en_GB.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    consolePackages = with pkgs; [
      terminus_font
    ];
    consoleFont = "ter-132n";
  };

  environment.systemPackages = with pkgs; [
    bind
    git
    htop
    iotop
    lsof
    ncdu
    pciutils
    psmisc
    ripgrep
    rsync
    stow
    strace
    tig
    tmux
    traceroute
    tree
    vimHugeX
  ];

  programs.bash.enableCompletion = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    permitRootLogin = "no";
  };

  programs.mosh.enable = true;

  services.nscd.enable = false;

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
