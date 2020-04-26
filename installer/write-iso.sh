#!/usr/bin/env bash
set -eu

if [[ $# -ne 2 ]]; then
  echo >&2 "Usage: $(basename "$0") ISO DEVICE"
  exit 1
fi

iso=$1
dev=$2
if [[ ! -b $(readlink -f "$dev") ]]; then
  echo >&2 "Not a block device: $dev"
  exit 1
fi

iso_size=$(stat -c %s "$1")

if [[ -f "$iso.sha256" ]]; then
  (cd "$(dirname "$iso")" && sha256sum -c "$iso.sha256")
fi

dd if="$iso" of="$dev" bs=4M

sha256sum "$iso"
head -c "$iso_size" "$dev" | sha256sum

