{ config, lib, pkgs, ... }:

{
  imports = [
    ./overlays.nix
  ];

  environment.systemPackages = with pkgs; [
    bind
    dos2unix
    file
    git
    gnupg
    htop
    iotop
    lsof
    ncdu
    nftables
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
