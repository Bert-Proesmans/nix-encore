{
  sources,
  lib,
  pkgs,
  config,
  ...
}:
let
  wallpaper = ./the_creation_of_adam.jpg;
in
{
  imports = [
    (sources.disko + "/module.nix")
    ./hardware-configuration.nix
    ../nixos/home-manager.nix
    ../nixos/internationalisation.nix
    ../nixos/nix.nix
  ];

  environment.systemPackages = [
    pkgs.nixfmt
    pkgs.vscodium
  ];

  networking.hostName = "lenny";
  networking.networkmanager = {
    enable = true;
    # Enables automatic low-power mode
    wifi.powersave = true;
  };
  nix.settings.trusted-public-keys = [
    "development.local-1:Wq31nOqkJWq1EIMabjKnLSCdlPwb5xmsZDur+RZNE4I="
  ];

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      # For GUIs
      fira
      ubuntu-classic

      # For editors/terminals
      dejavu_fonts
      fira-code
      fira-code-symbols
      # symbola # non-free
      nerd-fonts.jetbrains-mono

      # For design software
      montserrat
      open-sans
    ];
  };

  environment.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
  };

  # ---
  programs.hyprland = {
    enable = true;
  };
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk # GTK's portal
  ];
  services.displayManager.ly.enable = true; # Login manager

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
      };
    };
  };

  home-manager.users.bert-proesmans = { lib, config, pkgs, ...}: {
    home.stateVersion = "26.05";
    # theme = {
    #   enable = true;
    #   font = {
    #     size = 13;
    #     family = "JetBrains Mono";
    #   };
    #   gtk.enable = true;
    # };

    programs.rofi = {
      enable = true;
      font = "JetBrains Mono 20";
      modes = [
        "drun"
        "calc"
        "emoji"
        "run"
      ];
      plugins = with pkgs; [
        rofi-calc
        rofi-emoji
      ];
      extraConfig = {
        modi = "drun,calc,emoji,run";

        kb-remove-char-back = "Alt+h,BackSpace,Shift+BackSpace";
        kb-mode-complete = "Alt+l";
        kb-row-up = "Up,Control+k,Shift+Tab,Shift+ISO_Left_Tab";
        kb-row-down = "Down,Control+j";
        kb-accept-entry = "Control+m,Return,KP_Enter";
        kb-remove-to-eol = "Control+Shift+e";
        kb-mode-next = "Control+l";
        kb-mode-previous = "Control+h";

        display-drun = "[Apps]";
        display-run = "[Packages]";
        display-emoji = "[Emoji]";
        display-calc = "[Calculator]";
        drun-display-format = "{name} {icon}";
        show-icons = false;
      };
    };
    programs.rofi.theme = "${pkgs.writeText "config.rasi" ''
      * {
        base: #000000;
        text: #f0f0f0;
        lightbase: #202020;
        accent: #999999;
        border-radius: 4;
        background-color: @base;
        text-color: @text;
        font: "JetBrains Mono 26";
        width: 12em;
      }

      element {
        orientation: horizontal;
        children: [ element-text ];
        spacing: 4px;
        cursor: pointer;
      }

      window {
        border-color: @accent;
        border: 2px;
      }

      entry{ 
        expand: true;
        background-color: @lightbase;
        placeholder: "...";
      }

      element-text {
        cursor: pointer;
        background-color: @base;
        text-color: @text;
        vertical-align: 0.5;
        horizontal-align: 0;
      }
      element-text selected, element-icon selected {
        background-color: @lightbase;
        border-radius: 0;
      }

      element-icon {
        size:1em;
      }
    ''}";

    programs.waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "bottom";
          spacing = 8;

          modules-left = [
            "custom/distrologo"
            "hyprland/workspaces"
            "hyprland/language"
          ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "tray"
            "battery"
            "battery#bat1"
            "pulseaudio"
            "clock"
            "custom/power"
          ];

          "hyprland/workspaces" = {
            format = "[{name}]";
            format-icons = {
              urgent = "[!]";
              focused = "[]";
              default = "[]";
            };
            persistent-workspaces = {
              "*" = [
                1
                2
                3
                4
                5
              ];
            };
          };
          "hyprland/language" = {
            format = "[{short}]";
          };
          tray = {
            icon-size = 20;
            spacing = 2;
          };
          clock = {
            format = "[{:%H:%M}]";
            format-alt = "[{:%Y-%m-%d}]";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };
          cpu = {
            format = "[ {usage}%]";
            tooltip = false;
          };
          memory = {
            format = "[ {}%]";
          };
          temperature = {
            thermal-zone = 5;
            critical-threshold = 80;
            format-critical = "{temperatureC}°C {hot}";
            format-icons = [ "" ];
            format = "[{icon} {temperatureC}°C]";
          };
          battery = {
            bat = "BAT0";
            states = {
              good = 85;
              warning = 30;
              critical = 15;
            };
            format = "[{capacity}% {icon}]";
            format-full = "[{capacity}% {icon}]";
            format-charging = "[{capacity}% ]";
            format-plugged = "[{capacity}% ]";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
          "battery#bat1" = {
            bat = "BAT1";
            states = {
              good = 85;
              warning = 30;
              critical = 15;
            };
            format = "[{capacity}% {icon}]";
            format-full = "[{capacity}% {icon}]";
            format-charging = "[{capacity}% ]";
            format-plugged = "[{capacity}% ]";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
          "power-profiles-daemon" = {
            format = "{icon}";
            tooltip-format = "Power profile: {profile}\nDriver: {driver}";
            tooltip = true;
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
          };
          pulseaudio = {
            scroll-step = 2.5;
            format = "[{icon} {volume}%]";
            format-bluetooth = "{volume}% {icon} ";
            format-bluetooth-muted = " {icon} ";
            format-muted = " Muted";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };
          "custom/power" = {
            format = "[⏻]";
            tooltip = true;
            tooltip-format = "Suspend system";
            on-click = "systemctl suspend";
          };
          "custom/wifi" = {
            format = "";
            tooltip = false;
            on-click = "nm-connection-editor";
          };
          "custom/bluetooth" = {
            format = "";
            tooltip = false;
            on-click = "blueberry";
          };
          "custom/distrologo" = {
            format = "[{icon}]";
            tooltip-format = "I'm using NixOS BTW";
            tooltip = true;
            format-icons = {
              default = "";
            };
            on-click = "rofi -modi drun,calc,emoji,run -show drun -no-persist-history";
          };
        }
      ];
    };
    programs.waybar.style = ''
      * {
          font-family: JetBrainsMono Nerd Font Propo;
          font-size: 13pt;
          border-radius: 4px;
          margin: 0;
          padding: 0;
      }

      window#waybar {
          background-color: black;
          border-radius: 0px;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          color: white;
          background-color: rgba(32, 32, 32, 1);
      }

      #power,
      #clock,
      #pulseaudio,
      #battery {
          padding: 0 2;
          margin: 0 2;
      }

      #clock:hover,
      #pulseaudio:hover,
      #battery:hover {
          background-color: rgba(48, 48, 48, 1);
      }

      #workspaces {
          background-color: #000000;
          border-radius: 4px;
      }

      #workspaces button {
          padding: 0 4;
      }

      #workspaces button:hover {
          background-color: rgba(48, 48, 48, 1);
      }

      #workspaces button.active {
          background-color: #303030;
          border-bottom: 4px solid #404040;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }
    '';

    services.dunst =
      let
        frame = "#89b4fa";
        bg = "#1e1e2e";
        fg = "#cdd6f4";
        cornerRadius = builtins.toString 4;
      in
      {
        enable = true;
        settings = {
          global = {
            frame_color = "${frame}";
            separator_color = "frame";
            highlight = "${frame}";
            corner_radius = "${cornerRadius}";
            font = "JetBrains Mono 13";
          };
          urgency_normal = {
            background = "${bg}";
            foreground = "${fg}";
            timeout = 3;
          };
        };
      };

    services.hyprpaper = {
      enable = true; # Wallpaper utility
      package = pkgs.hyprpaper;
      settings = {
        preload = [ "${wallpaper}" ];
        wallpaper = [ ",${wallpaper}" ];
      };
    };

    services.swayosd.enable = true; # OSD

    home.packages = with pkgs; [
      wlsunset # Blue light filter
      hyprpolkitagent # Authentification agent
      hyprshot # Screenshot utility
      blueman # Bluetooth control
      networkmanagerapplet # Network control
      pavucontrol # Audio control
      libnotify # Notification daemon
    ];

    # Session variables
    home.sessionVariables = {
      XDG_PICTURES_DIR = "$HOME/Pictures";
      HYPRSHOT_DIR = "$HOME/Pictures/Screenshots";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true; # Auto-start for services
      xwayland.enable = true;
      settings.animations.enabled = "no";

      settings.debug.full_cm_proto = true; # scRGB support
    };
  };

  # ---

  # programs.firefox.enable = true;
  # programs.hyprland = {
  #   enable = true;
  #   withUWSM = false;
  #   xwayland.enable = true; # Xwayland can be disabled.
  # };
  # programs.hyprlock.enable = true;
  # services.hypridle.enable = true;

  # services.greetd = {
  #   enable = true;
  #   useTextGreeter = true;
  #   settings =
  #     let
  #       startHyprland = "/run/current-system/sw/bin/start-hyprland";
  #     in
  #     {
  #       # Automatic sign-in. The sign-in through greeter is kept because that breaks a crashloop if something would happen to hyprland
  #       initial_session = {
  #         command = startHyprland;
  #         user = config.users.users.bert-proesmans.name;
  #       };
  #       default_session = {
  #         command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --cmd ${startHyprland}";
  #         # user = "greeter"; # Implicitly set by greetd
  #       };
  #     };
  # };

  # programs.hyprland = {
  #   enable = true;
  #   withUWSM = true;
  #   systemd.setPath.enable = true;
  # };

  # programs.dms-shell = {
  #   enable = true;
  #   systemd.enable = true;
  #   enableSystemMonitoring = true;
  #   enableDynamicTheming = true;
  # };

  # services.greetd = {
  #   enable = true;
  #   # settings.default_session = {
  #   #   command = "uwsm start -eD Hyprland hyprland.desktop";
  #   #   # user = config.user.name;
  #   # };
  # };
  # services.displayManager = {
  #   autoLogin = {
  #     enable = true;
  #     user = "bert-proesmans";
  #   };

  #   dms-greeter = {
  #     enable = true;
  #     compositor.name = "hyprland";
  #   };
  # };

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
    packages = [
      # (catppuccin-kvantum.override {
      #   variant = "mocha";
      #   accent = "blue";
      # })
      # (graphite-gtk-theme.override {
      #   themeVariants = [ "pink" ];
      #   colorVariants = [ "dark" ];
      #   # sizeVariants = [ "compact" ];
      #   tweaks = [
      #     "normal"
      #     "rimless"
      #     "darker"
      #   ];
      # })
      # (catppuccin-papirus-folders.override {
      #   flavor = "mocha";
      #   accent = "blue";
      # })
      pkgs.catppuccin-cursors.mochaDark
      pkgs.tela-circle-icon-theme
      pkgs.dracula-icon-theme

      # (mkLauncherEntry "Toggle night mode" {
      #   icon = "redshift";
      #   exec = "dms ipc night toggle";
      # })
    ];
  };

  # home-manager.users.bert-proesmans = { lib, ... }: {
  #   home.stateVersion = "26.05";
  #   # Hint electron apps to use Wayland
  #   # home.sessionVariables.NIXOS_OZONE_WL = "1";

  #   programs.kitty.enable = true; # required for the default Hyprland config

  #   wayland.windowManager.hyprland = {
  #     enable = true;
  #     # Direct systemd integration conflicts with Universal Wayland Session Manager (UWSM)
  #     # systemd.enable = false;
  #     systemd.enable = true;
  #     # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
  #     package = null;
  #     portalPackage = null;

  #     configType = "lua";
  #     settings = {
  #       config = {
  #         exec-once = [
  #           "quickshell"
  #         ];

  #         general = {
  #           gaps_in = 5;
  #           gaps_out = 20;
  #           border_size = 2;
  #         };

  #         decoration = {
  #           rounding = 10;
  #         };

  #         ecosystem = {
  #           no_update_news = true;
  #           no_donation_nag = true;
  #         };
  #       };

  #       # NOTE; SUPER key is [Windows] key
  #       bind = [
  #         {
  #           _args = [
  #             "SUPER + L"
  #             (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-sink-mute @DEFAULT_SINK@ 1 ; hyprlock\")")
  #           ];
  #         }
  #         {
  #           _args = [
  #             "SUPER + RETURN"
  #             (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
  #           ];
  #         }
  #         {
  #           _args = [
  #             "SUPER + S"
  #             (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special(\"magic\")")
  #           ];
  #         }
  #       ];
  #     };
  #   };

  #   programs.hyprlock.enable = true;
  #   services.hypridle.enable = true;
  #   programs.quickshell = {
  #     enable = true;
  #     activeConfig = "grayscale";
  #     configs.grayscale = ./quickshell-grayscale.qml;
  #   };
  # };

}
