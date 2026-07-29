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

  # Ensure greetd is not enabled anywhere by default (hosts can override if needed)
  services.greetd.enable = false;

  # Animations  "doom", "colormix", "matrix"
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      bigclock = true;
      # --- Color Settings (0xAARRGGBB) ---
      # Background color of dialog box (Black)
      bg = "0x00000000";
      # Foreground text color (Cyan: #00FFFF)
      fg = "0x0000FFFF";
      # Border color (Red: #FF0000)
      border_fg = "0x00FF0000";
      # Error message color (Red)
      error_fg = "0x00FF0000";
      # Clock color (Purple: #800080)
      clock_color = "#800080";
    };
  };

  # Compositor (Niri)
  programs.niri.enable = true;

  # Basic system packages
  environment.systemPackages = [
    pkgs.nixfmt
    pkgs.vscodium
  ];

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
