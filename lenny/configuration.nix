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

  environment.systemPackages = [ pkgs.nixfmt ];

  networking.hostName = "lenny";
  networking.networkmanager = {
    enable = true;
    # Enables automatic low-power mode
    wifi.powersave = true;
  };
  nix.settings.trusted-public-keys = [
    "development.local-1:Wq31nOqkJWq1EIMabjKnLSCdlPwb5xmsZDur+RZNE4I="
  ];

  programs.firefox.enable = true;
  programs.hyprland = {
    enable = true;
    # Configure dbus
    withUWSM = false;
    xwayland.enable = true; # Xwayland can be disabled.
  };
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings =
      let
        startHyprland = "/run/current-system/sw/bin/start-hyprland";
      in
      {
        # Automatic sign-in. The sign-in through greeter is kept because that breaks a crashloop if something would happen to hyprland
        initial_session = {
          command = startHyprland;
          user = config.users.users.bert-proesmans.name;
        };
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --cmd ${startHyprland}";
          # user = "greeter"; # Implicitly set by greetd
        };
      };
  };

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
    enable = true;
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

  # TODO; Doesn't work without singular host config entry point!
  # system.copySystemConfiguration = true;
  system.stateVersion = "26.05";
  time.timeZone = "Europe/Brussels";

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

  home-manager.users.bert-proesmans = { lib, ... }: {
    home.stateVersion = "26.05";
    # Hint electron apps to use Wayland
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.kitty.enable = true; # required for the default Hyprland config

    wayland.windowManager.hyprland = {
      enable = true;
      # Direct systemd integration conflicts with Universal Wayland Session Manager (UWSM)
      systemd.enable = false;
      # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
      package = null;
      portalPackage = null;

      configType = "lua";
      settings = {
        config = {
          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
          };
          decoration = {
            rounding = 10;
          };
        };

        # NOTE; SUPER key is [Windows] key
        bind = [
          {
            _args = [
              "SUPER + L"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-sink-mute @DEFAULT_SINK@ 1 ; hyprlock\")")
            ];
          }
          {
            _args = [
              "SUPER + RETURN"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
            ];
          }
          {
            _args = [
              "SUPER + S"
              (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special(\"magic\")")
            ];
          }
        ];
      };
    };

    programs.hyprlock.enable = true;
  };

}
