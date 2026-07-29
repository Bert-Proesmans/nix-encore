#!/usr/bin/env bash
# run-lenny-vm.sh
#
# Builds and runs the lenny VM with nixGL so QEMU can access the host GPU
# for hardware-accelerated 3D rendering (required by niri compositor).
#
# nixGL bridges the gap between Nix-compiled QEMU and the host's Mesa/GPU drivers.
# --impure is required because nixGL inspects host hardware at runtime.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building lenny VM..."
nix-build systems.nix -A lenny.config.system.build.vm

echo "Launching VM with nixGL..."
exec nix run --impure github:nix-community/nixGL -- ./result/bin/run-lenny-vm
