{ config, lib, pkgs, ... }:

{
  imports = [
    ./overlays.nix
  ];

  environment.systemPackages = with pkgs; [
    bind
    file
    git
    gnupg
    htop
    iotop
    lsof
    ncdu
    pciutils
    pinentry-curses
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
}