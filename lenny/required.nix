{
  sources,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    (sources.disko + "/module.nix")
    ./hardware-configuration.nix
    ../nixos/home-manager.nix
    ../nixos/internationalisation.nix
    ../nixos/nix.nix
  ];

  networking.hostName = "lenny";
  networking.networkmanager = {
    enable = true;
    # Enables automatic low-power mode
    wifi.powersave = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old --delete-older-than 7d";
  };
  nix.settings.trusted-public-keys = [
    "development.local-1:Wq31nOqkJWq1EIMabjKnLSCdlPwb5xmsZDur+RZNE4I="
  ];

  # TODO; Doesn't work without singular host config entry point!
  # system.copySystemConfiguration = true;
  system.stateVersion = "26.05";
  time.timeZone = "Europe/Brussels";

  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  services.openssh.enable = true;
  services.resolved.enable = true;

  # DEBUG
  users.users.bert-proesmans.password = "testing123"; # DEBUG

  users.mutableUsers = false;
  users.users.bert-proesmans = {
    isNormalUser = true;
    description = "Bert Proesmans";
    extraGroups = [
      "wheel" # Enable 'sudo' for the user
      "systemd-journal" # Read the systemd service journal without sudo
      # Allow managing networking using nmtui/nmcli (NetworkManager)
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOs8kDMMm/QFeELt79EG9akdfX7dlfRuTezwVEqbPsM bert@B-PC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEeQ/KEIWbUKBc4bhZBUHsBB0yJVZmBuln8oSVrtcA5 bert@B-PC"
    ];
    packages = [ ];
  };
}
