#!/usr/bin/env bash
set -eu

base=$(git rev-parse --show-toplevel)

NIXOS_CONFIG="$base/installer/configuration.nix" nix-build "<nixpkgs/nixos>" -A config.system.build.isoImage

