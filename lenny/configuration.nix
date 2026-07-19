{ sources, pkgs, ... }: {
  system.stateVersion = "26.05";

  imports = [
    sources.nixos-vscode-server
    (sources.disko + "/module.nix")
    ./hardware-configuration.nix
  ];

  environment.systemPackages = [ pkgs.nixfmt ];

  services.vscode-server.enable = true;
}
