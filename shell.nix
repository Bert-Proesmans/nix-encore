# Version-pinned dependencies, managed through the "lon" CLI.
{
  # REF; https://github.com/nikstur/lon
  sources ? (import ./lon.nix),
}:
let
  pkgs = import sources.nixpkgs { system = builtins.currentSystem; };
  treefmt-nix = import sources.treefmt-nix;

  # Function that wraps and tests nushell scripts
  writeNuApplication = pkgs.callPackage ./maintainer/writeNuApplication.nix { };
in
pkgs.mkShellNoCC {
  name = "Nix-encore shell";

  NIXPKGS = "${sources.nixpkgs}";

  packages = [
    # Adds command treefmt to PATH, for formatting the codebase files
    (treefmt-nix.mkWrapper pkgs ./maintainer/treefmt.nix)
    pkgs.lon # Source revision control
    pkgs.nix-tree # Browse derivation output

    (writeNuApplication {
      name = "e2e-test";
      runtimeInputs = [
        # pkgs.coreutils
        # pkgs.findutils
        pkgs.nix-output-monitor
        # pkgs.qemu
        # pkgs.openssh
        pkgs.strace # Debugging
      ];
      runtimeEnv = {
        OVMF_CODE = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd";
        OVMF_VARS = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
      };
      # checkPhase = "";
      text = builtins.readFile ./maintainer/e2e-test.nu;
      # text = ''
      #   print Hello
      #   print $env.PATH
      #   nom --help
      # '';
    })
    (writeNuApplication {
      name = "deploy";
      runtimeInputs = [
        pkgs.nix-output-monitor # For building and introspection
        pkgs.nixos-anywhere # Deploy new hosts
        pkgs.nixos-rebuild-ng
        pkgs.runtimeShell # Shell out to bash to apply sensitive arguments
      ];
      text = builtins.readFile ./maintainer/deploy.nu;
    })
  ];
}
