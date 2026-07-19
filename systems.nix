{
  self ? (import ./. { }),
  # Version-pinned dependencies, managed through the "lon" CLI.
  # REF; https://github.com/nikstur/lon
  sources ? (import ./lon.nix),
}:
let

  # Collection of helper methods.
  # SEEALSO; https://noogle.dev
  lib = (import (sources.nixpkgs + "/lib")).extend (
    final: _prev: {
      # WARN; Extend by namespacing additional functionality to not clobber symbols used by upstream/downstream code!s

      # Includes runTest and evalModules helpers.
      nixos = import (sources.nixpkgs + "/nixos/lib") { lib = final; };
    }
  );

  _nixosSystemFunc = import (sources.nixpkgs + "/nixos/lib/eval-config.nix");
  # Function that wraps system configuration into something to be eval'ed and built.
  nixosSystem =
    newArgs:
    _nixosSystemFunc (
      {
        inherit lib;
        system = null; # Deprecated
        pkgs = null; # Deprecated
      }
      // newArgs
    );
in
{
  # Setting outPath makes (toString self) work eg, "${self}/functionality.nix"
  outPath = ./.;

  lenny = {
    system = nixosSystem {
      specialArgs = { inherit self sources; };
      modules = [ ./lenny/configuration.nix ];
    };

    home = { };
  };
}
