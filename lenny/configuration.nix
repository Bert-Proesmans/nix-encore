{
  sources,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ ./required.nix ];

  # System-level environment variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Forward port 2222 on the host to port 22 on the VM
  virtualisation.vmVariant = {
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
    virtualisation.qemu.options = [
      "-vga"
      "none"
      "-device"
      "virtio-vga-gl"
      "-display"
      "gtk,gl=on"
    ];
  };

  # Fonts
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
      nerd-fonts.jetbrains-mono

      # For design software
      montserrat
      open-sans
    ];
  };

  # Display Manager (Login Screen)
  services.displayManager.ly.enable = true;

  # Compositor (Niri)
  programs.niri.enable = true;

  # Basic system packages
  environment.systemPackages = [
    pkgs.nixfmt-rfc-style
    pkgs.vscodium
  ];

  # DankMaterialShell (provides locker, topbar, launcher)
  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
  };

  home-manager.users.bert-proesmans =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      home.stateVersion = "26.05";

      programs.kitty.enable = true;

      xdg.configFile."niri/config.kdl".text = ''
        input {
            keyboard {
                xkb {
                }
            }
            touchpad {
                tap
                natural-scroll
            }
        }
        // Force 1280x720 on the QEMU virtual display
        output "Virtual-1" {
            mode "1280x720"
        }
        layout {
            gaps 10
            border { width 2; }
        }
        binds {
            // Essential bindings
            Mod+Return { spawn "kitty"; }
            Mod+L { spawn "loginctl" "lock-session"; }
            Mod+Q { close-window; }
            Mod+Shift+E { quit; }

            // Movement
            Mod+Left  { focus-column-left; }
            Mod+Right { focus-column-right; }
            Mod+Up    { focus-window-up; }
            Mod+Down  { focus-window-down; }
            Mod+Ctrl+Left  { move-column-left; }
            Mod+Ctrl+Right { move-column-right; }
            Mod+Ctrl+Up    { move-window-up; }
            Mod+Ctrl+Down  { move-window-down; }
        }
      '';
    };
}
