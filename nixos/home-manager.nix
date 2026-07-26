{ sources, pkgs, ... }:
let
  home-manager = import sources.home-manager { inherit pkgs; };
in
{
  imports = [ home-manager.nixos ];

  # Enable more output when switching configuration
  home-manager.verbose = true;
  # Home-manager manages software assigned through option users.users.<name>.packages
  home-manager.useUserPackages = true;
  # Follow the system nix configuration instead of building/using a parallel index
  home-manager.useGlobalPkgs = true;
}
