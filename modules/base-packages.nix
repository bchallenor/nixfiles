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
