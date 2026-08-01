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

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspendThenHibernate = "yes";
    HibernateDelaySec = "30m";
  };

  # Prevent (Intel) CPU overheating
  services.thermald.enable = true;
  services.tlp = {
    # Automatically adjust system power profiles
    enable = false;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20; # ??

      # Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 75; # charge below 75
      STOP_CHARGE_THRESH_BAT0 = 80; # stop charging at or above 80
    };
  };


  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  services.openssh.enable = true;

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
