{
  sources,
  pkgs,
  config,
  ...
}:
let
  noctalia = import sources.noctalia { inherit pkgs; };
in
{
  imports = [ ./required.nix ];

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

  # System-level environment variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    MOZ_ENABLE_WAYLAND = "1";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    # WARN; Requires rtkit configuration! (resolved above)
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber = {
      enable = true;
      # Explicitly enable high-quality extra codecs and hardware volume
      extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };
      };
    };
  };

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = config.users.users.bert-proesmans.name;
    ly = {
      # NOTE; Check Ly releases because v1.5.0 will bring a couple of improvements!
      # REF; https://codeberg.org/fairyglade/ly/releases
      enable = true;
      settings = {
        # Input box active by default on startup
        # Available inputs: info_line, session, login, password
        default_input = "password";
        # ERROR; Ly hangs on empty password text-field requirement when configured to autologin.
        allow_empty_password = config.services.displayManager.autoLogin.enable;
        # Erase password input on failure
        clear_password = true;

        # The number of failed authentications before a special animation is played... ;)
        # If set to 0, the animation will never be played
        auth_fails = 2;

        # Command executed when no input is detected for a certain time
        # If null, no command will be executed
        # inactivity_cmd = null; # TODO

        # Executes a command after a certain amount of seconds
        inactivity_delay = 30;

        # Initial text to show on the info line
        # If set to null, the info line defaults to the hostname
        # initial_info_text = null;

        # Active language
        # Available languages are found in $CONFIG_DIRECTORY/ly/lang/
        lang = "en";

        # Set numlock on/off at startup
        numlock = true;

        # Show the shell session in the session list
        # If false, the shell session will be hidden
        # ERROR; 'shell' is broken! Ly is probably attempting to launch the default shell without considering
        # proper (nixos) environment.
        shell = false;

        # Specifies the key combination used for showing the password
        # If null, the keybind is disabled and isn't shown
        # show_password_key = null; # BROKEN??

        brightness_down_key = null;
        brightness_up_key = null;

        # If true, user will need to manually type username instead of selecting from the list
        # of discovered users
        type_username = false;

        # Render true colors (if supported)
        # If false, output will be in eight-color mode
        # All eight-color mode color codes:
        # TB_DEFAULT              0x0000
        # TB_BLACK                0x0001
        # TB_RED                  0x0002
        # TB_GREEN                0x0003
        # TB_YELLOW               0x0004
        # TB_BLUE                 0x0005
        # TB_MAGENTA              0x0006
        # TB_CYAN                 0x0007
        # TB_WHITE                0x0008
        # If full color is off, the styling options still work. The colors are
        # always 32-bit values with the styling in the most significant byte.
        # Note: If using the dur_file animation option and the dur file's color range
        # is saved as 256 with this option disabled, the file will not be drawn.
        full_color = true;

        # Ly supports 24-bit true color with styling, which means each color is a 32-bit value.
        # The format is 0xSSRRGGBB, where SS is the styling, RR is red, GG is green, and BB is blue.
        # Here are the possible styling options:
        # TB_BOLD      0x01000000
        # TB_UNDERLINE 0x02000000
        # TB_REVERSE   0x04000000
        # TB_ITALIC    0x08000000
        # TB_BLINK     0x10000000
        # TB_HI_BLACK  0x20000000
        # TB_BRIGHT    0x40000000
        # TB_DIM       0x80000000
        # Programmatically, you'd apply them using the bitwise OR operator (|), but because Ly's
        # configuration doesn't support using it, you have to manually compute the color value.
        # Note that, if you want to use the default color value of the terminal, you can use the
        # special value 0x00000000. This means that, if you want to use black, you *must* use
        # the styling option TB_HI_BLACK (the RGB values are ignored when using this option).

        # Text color for everything (Purple: #800080)
        fg = "0x40800080";
        # Input boxes length
        input_len = 34;

        # The active animation
        # none     -> Nothing
        # doom     -> PSX DOOM fire
        # matrix   -> CMatrix
        # colormix -> Color mixing shader
        # gameoflife -> John Conway's Game of Life
        # dur_file -> .dur file format (https://github.com/cmang/durdraw/tree/master)
        # lua -> user-made animation written in LuaJIT
        animation = "dur_file";
        dur_file_path = "${sources.ly-themes}/animations/dur/blackhole-smooth-240x67.dur";
        # Delay between each animation frame in milliseconds
        animation_frame_delay = 20;

        # Dur file alignment
        # The dur file can be aligned with a direction and centered easily with the flags below
        # Available inputs: topleft, topcenter, topright, centerleft, center, centerright, bottomleft, bottomcenter, bottomright
        dur_offset_alignment = "center";

        # Dur offset x direction (value is added to the current position determined by alignment, negatives are supported)
        # dur_x_offset = 0

        # Dur offset y direction (value is added to the current position determined by alignment, negatives are supported)
        dur_y_offset = 6;

        # Title to show at the top of the main box
        # If set to null, none will be shown
        box_title = null;

        bigclock = "none"; # 'en' enables clock
        bigclock_12hr = false;
        bigclock_seconds = false;

        # Screen corners customization
        # Keywords:
        # shutdown -> Shutdown key
        # restart  -> Restart key
        # britup   -> Brightness up key
        # britdown -> Brightness down key
        # password -> Toggle password key
        # clock    -> Clock (format defined by 'clock' option)
        # tty      -> Active TTY number
        # battery  -> Battery percentage
        # version  -> Ly version string
        # numlock  -> Numlock state
        # capslock -> Capslock state
        # labels   -> All custom info labels (lbl:)
        # binds    -> All custom keybind hints (cmd:)
        # lbl:name -> Specific custom info label
        # cmd:key  -> Specific custom keybind hint
        #
        # If using a keyword that groups multiple labels into one (e.g. labels, binds),
        # they'll be placed horizontally
        #
        # Also, the order defines the vertical stack (first item is at the edge)
        # If items are separted by commas, they'll be placed horizontally
        # It is possible to have both horizontal and vertical items on the same corner

        corner_bottom_left = "tty";
        corner_bottom_right = "labels";
        corner_top_left = "shutdown,restart battery";
        corner_top_right = "clock numlock,capslock";

        # For custom binds: the horizontal limit in characters for each
        # line of custom binds before moving on to the next.
        # If null, defaults to the width of the terminal instead.
        # custom_bind_width = null

        # Format string for clock in top right corner (see strftime specification). Example: %c
        # If null, the clock won't be shown
        clock = "%a, %d %b %Y";

        # Identifier for battery whose charge to display at top left
        # Primary battery is usually BAT0 or BAT1
        # If set to null, battery status won't be shown
        # Unused on FreeBSD (a sysctl is used there)
        battery_id = "BAT0";

        # Custom Commands and Labels:
        # The following examples below give an outline for setting up custom commands and labels.
        # Unless specified as optional, an option is mandatory.

        # Comments preceding with '##' are for documentation.
        # Comments preceding with '#' comment out the example INI.

        # Declare a command with the F8 binding.
        # [cmd:F8]
        # The name of the command to show up in Ly.
        # Note: "$" in "$brightness_up" fetches the appropriate string from the specified locale file
        # and is replaced with the value representing "brightness_up".
        # You can see the list of keys in any locale file in $CONFIG_DIRECTORY/ly/lang.
        # cmd = touch /tmp/ly.gaming
        # name = custom command $brightness_up

        # Declare a label with an ID. This ID should be unique across all labels.
        # [lbl:kernel]
        # cmd = uname -srn
        # Optional, defaulting to 0.
        # In frames, the time to re-run the command and update the label.
        # If 0, only run once and do not refresh afterwards
        # refresh = 0

        # Prevent reported error of 'custom_sessions' directory not existing.
        # Config value should be pushed upstream.
        custom_sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
      };
    };
  };

  # Compositor
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  # Desktop shell
  programs.noctalia = {
    enable = true;
    systemd.enable = true; # This is a user service
    # networking.networkmanager.enable
    # hardware.bluetooth.enable
    # services.upower.enable
    # services.power-profiles-daemon.enable
    recommendedServices.enable = true;
  };

  programs.firefox = {
    # NOTE; Firefox is _wrapped_ with the policies, there is no global/local config, and a firefox on system PATH could become the wrong
    # firefox. As in, missing policies that are applied through home-manager.
    #
    # ERROR; Make sure that the home-manager wrapped version of firefox is found FIRST on PATH!
    # Use 'config.programs.firefox.finalPackage' as starting point for wrapping.
    enable = true;

    languagePacks = [
      "en-GB"
      "nl"
      "fr"
    ];

    preferences = {
      "browser.startup.homepage" = "https://wiki.proesmans.eu";
      "privacy.resistFingerprinting" = true;
    };

    policies = { };
  };

  # Basic system packages
  environment.systemPackages = [
    pkgs.brightnessctl
    # pkgs.wireplumber # wpctl -> activated by services.pipewire.wireplumber
    pkgs.playerctl
    pkgs.libnotify # notify-send
    pkgs.wl-mirror
    pkgs.jq

    pkgs.nixfmt
    pkgs.vscodium

    pkgs.pciutils # lspci
    pkgs.usbutils # lsusb
  ];

  home-manager.users.bert-proesmans =
    {
      config,
      osConfig,
      ...
    }:
    {
      imports = [ noctalia.homeModule ];
      home.stateVersion = "26.05";

      # TODO; Prepare audio pipeline preset to correct the dogshit audio coming from the laptop speakers.
      services.easyeffects.enable = true;

      programs.alacritty = {
        enable = true;
        settings = {
          font = {
            size = 11;
            normal = {
              family = "JetBrainsMono Nerd Font";
              style = "Regular";
            };
          };
        };
      };

      wayland.windowManager.niri = {
        enable = true;
        checkConfig = true;
        systemd.enable = true;
        # See environment.sessionVariables = {};
        # systemd.variables = [ ];
        xwaylandSatellitePackage = null; # No XWayland for security reasons
        portalPackage = null; # Portal packages are set in system config
        settings = {
          # The output config is in the KDL format: https://kdl.dev
          #
          # Check the wiki for a full description of the configuration:
          # https://niri-wm.github.io/niri/Configuration:-Introduction
          #
          # WARN; An empty config node removes all defaults and resets toplevel primitive values to "initialized at empty".

          debug = {
            # Allows notification actions and window activation from Noctalia.
            #
            # ERROR; This is also a workaround for Electron/Qt applications that fail to report a valid window serial when launching (main) windows
            # from notification or icon.
            # REF; https://niri-wm.github.io/niri/Configuration%3A-Debug-Options.html#honor-xdg-activation-with-invalid-serial
            honor-xdg-activation-with-invalid-serial = { };
          };

          input = {
            # Enable numlock on startup, omitting this setting disables numlock.
            keyboard.numlock = { };
            touchpad = {
              tap = { };
              natural-scroll = { };
            };
            # mouse = { };
            # trackpoint = { };
            # Focus windows and outputs automatically when moving the mouse into them.
            # Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
            focus-follows-mouse._props = {
              max-scroll-amount = "0%";
            };
          };

          hotkey-overlay = {
            # Uncomment this line to disable the "Important Hotkeys" pop-up at startup.
            # skip-at-startup = {};
          };

          # Settings that influence how windows are positioned and sized.
          # Find more information on the wiki:
          # https://niri-wm.github.io/niri/Configuration:-Layout
          layout = {
            # Set gaps around windows in logical pixels.
            gaps = 4;

            # When to center a column when changing focus, options are:
            # - "never", default behavior, focusing an off-screen column will keep at the left
            #   or right edge of the screen.
            # - "always", the focused column will always be centered.
            # - "on-overflow", focusing a column will center it if it doesn't fit
            #   together with the previously focused column.
            center-focused-column = "never";

            # You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
            preset-column-widths._children = [
              # Proportion sets the width as a fraction of the output width, taking gaps into account.
              # For example, you can perfectly fit four windows sized "proportion 0.25" on an output.
              # The default preset widths are 1/3, 1/2 and 2/3 of the output.
              { proportion = 0.33333; }
              { proportion = 0.5; }
              { proportion = 0.66667; }

              # Fixed sets the width in logical pixels exactly.
              # { fixed = 1920; }
            ];

            # Likewise for height presets that "switch-preset-window-height" (Mod+Ctrl+Shift+R) toggles between.
            preset-window-heights._children = [
              { proportion = 0.5; }
            ];

            # You can change the default width of the new windows.
            # If you leave the brackets empty, the windows themselves will decide their initial width.
            default-column-width.proportion = 0.5;

            # By default focus ring and border are rendered as a solid background rectangle
            # behind windows. That is, they will show up through semitransparent windows.
            # This is because windows using client-side decorations can have an arbitrary shape.
            #
            # If you don't like that, you should uncomment `prefer-no-csd` below.
            # Niri will draw focus ring and border *around* windows that agree to omit their
            # client-side decorations.
            #
            # Alternatively, you can override it with a window rule called
            # `draw-border-with-background`.

            # You can change how the focus ring looks.
            focus-ring = {
              # Uncomment this line to disable the focus ring.
              # off = {};

              # How many logical pixels the ring extends out from the windows.
              width = 4;

              # Colors can be set in a variety of ways:
              # - CSS named colors: "red"
              # - RGB hex: "#rgb", "#rgba", "#rrggbb", "#rrggbbaa"
              # - CSS-like notation: "rgb(255, 127, 0)", rgba(), hsl() and a few others.

              # Color of the ring on the active monitor.
              active-color = "#7fc8ff";

              # Color of the ring on inactive monitors.
              #
              # The focus ring only draws around the active window, so the only place
              # where you can see its inactive-color is on other monitors.
              inactive-color = "#505050";

              # You can also use gradients. They take precedence over solid colors.
              # Gradients are rendered the same as CSS linear-gradient(angle, from, to).
              # The angle is the same as in linear-gradient, and is optional,
              # defaulting to 180 (top-to-bottom gradient).
              # You can use any CSS linear-gradient tool on the web to set these up.
              # Changing the color space is also supported, check the wiki for more info.
              #
              # active-gradient._props = { from="#80c8ff"; to="#c7ff7f"; angle=45; };

              # You can also color the gradient relative to the entire view
              # of the workspace, rather than relative to just the window itself.
              # To do that, set relative-to="workspace-view".
              #
              # inactive-gradient._props = { from="#505050"; to="#808080"; angle=45; relative-to="workspace-view"; };
            };

            # You can also add a border. It's similar to the focus ring, but always visible.
            border = {
              # The settings are the same as for the focus ring.
              # If you enable the border, you probably want to disable the focus ring.
              off = { };

              width = 4;
              active-color = "#ffc87f";
              inactive-color = "#505050";

              # Color of the border around windows that request your attention.
              urgent-color = "#9b0000";

              # Gradients can use a few different interpolation color spaces.
              # For example, this is a pastel rainbow gradient via in="oklch longer hue".
              #
              # active-gradient._props = { from="#e5989b"; to="#ffb4a2"; angle=45; relative-to="workspace-view"; in="oklch longer hue"; };

              # inactive-gradient._props = { from="#505050"; to="#808080"; angle=45; relative-to="workspace-view"; };
            };

            # You can enable drop shadows for windows.
            shadow = {
              # Uncomment the next line to enable shadows.
              # on = {};
            };

            # Struts shrink the area occupied by windows, similarly to layer-shell panels.
            # You can think of them as a kind of outer gaps. They are set in logical pixels.
            # Left and right struts will cause the next window to the side to always be visible.
            # Top and bottom struts will simply add outer gaps in addition to the area occupied by
            # layer-shell panels and regular gaps.
            struts = {
              # left = 64;
              # right = 64;
              # top = 64;
              # bottom = 64;
            };
          };

          # Uncomment this line to ask the clients to omit their client-side decorations if possible.
          # If the client will specifically ask for CSD, the request will be honored.
          # Additionally, clients will be informed that they are tiled, removing some client-side rounded corners.
          # This option will also fix border/focus ring drawing behind some semitransparent windows.
          # After enabling or disabling this, you need to restart the apps for this to take effect.
          # prefer-no-csd

          _children = [
            # Window rules let you adjust behavior for individual windows.
            # Find more information on the wiki:
            # https://niri-wm.github.io/niri/Configuration:-Window-Rules
            #
            {
              # Example: enable rounded corners for all windows.
              # (This example rule is commented out with a "/-" in front.)
              window-rule._children = [
                { geometry-corner-radius = 20; }
                { clip-to-geometry = true; }
              ];
            }
            {
              window-rule._children = [
                {
                  match._props = {
                    # This is the noctalia settings window
                    app-id = "dev.noctalia.Noctalia";
                  };
                }
                # Make it large and float
                { open-floating = true; }
                { default-column-width.fixed = 1080; }
                { default-window-height.fixed = 920; }
              ];
            }
            {
              # Open the Firefox picture-in-picture player as floating by default.
              window-rule._children = [
                # This app-id regular expression will work for both:
                # - host Firefox (app-id is "firefox")
                # - Flatpak Firefox (app-id is "org.mozilla.firefox")
                {
                  match._props = {
                    app-id = "firefox$";
                    title = "^Picture-in-Picture$";
                  };
                }
                { open-floating = true; }
              ];
            }
            {
              # Example: block out two password managers from screen capture.
              # (This example rule is commented out with a "/-" in front.)
              window-rule._children = [
                {
                  match._props.app-id = "^org\.keepassxc\.KeePassXC$";
                }
                {
                  match._props.app-id = "^org\.gnome\.World\.Secrets$";
                }
                {
                  # Use "screencast" instead if you want them visible on third-party screenshot tools.
                  block-out-from = "screen-capture";
                }
              ];
            }
            {
              # Indicate screencasted windows with red colors.
              window-rule._children = [
                {
                  match._props = {
                    is-window-cast-target = true;
                  };
                }
                {
                  focus-ring = {
                    active-color = "#f38ba8";
                    inactive-color = "#7d0d2d";
                  };
                }
                { border.inactive-color = "#7d0d2d"; }
                { shadow.color = "#7d0d2d70"; }
                {
                  tab-indicator = {
                    active-color = "#f38ba8";
                    inactive-color = "#7d0d2d";
                  };
                }
              ];
            }
            # Layer rules let you adjust behavior for individual layer-shell surfaces. They work similarly to Window rules.
            # Find more information on the wiki:
            # https://niri-wm.github.io/niri/Configuration:-Layer-Rules
            {
              # Make the niri overview mode a tad more fancy with blurred background in the backdrop.
              #
              # NOTE; Requires Noctalia configuration to render the backdrop.
              # REF; https://docs.noctalia.dev/v5/desktop/wallpaper/?section=backdrop#backdrop
              layer-rule._children = [
                {
                  match._props = {
                    namespace = "^noctalia-backdrop";
                  };
                }
                { place-within-backdrop = true; }
              ];
            }
            {
              # Disable xray on all our surfaces so it looks more realistic.
              # Noctalia publishes blur regions automatically when ext-background-effects is available.
              layer-rule._children = [
                {
                  match._props = {
                    namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$";
                  };
                }
                {
                  background-effect._children = [
                    { xray = false; }
                    # { blur = false; }
                  ];
                }
              ];
            }
            {
              # Enable blur on noctalia's window switcher and disable xray.
              layer-rule._children = [
                {
                  match._props = {
                    namespace = "noctalia-window-switcher";
                  };
                }
                {
                  background-effect._children = [
                    { blur = true; }
                    { xray = false; }
                  ];
                }
              ];
            }
          ];

          binds = {
            # Keys consist of modifiers separated by + signs, followed by an XKB key name
            # in the end. To find an XKB name for a particular key, you may use a program
            # like wev.
            #
            # "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
            # when running as a winit window.
            #
            # Most actions that you can bind here can also be invoked programmatically with
            # `niri msg action do-something`.

            # Mod-Shift-Comma, resolving to Mod-? in be keyboard, shows a list of important hotkeys.
            "Mod+Shift+Comma".show-hotkey-overlay = { };

            # Suggested binds for running programs: terminal, app launcher, screen locker.
            "Mod+T" = {
              _props = {
                hotkey-overlay-title = "Open a Terminal: alacritty";
              };
              spawn = [ "alacritty" ];
            };
            # ERROR; Niri currently does not accept the MOD key on its own as a keybind! The code is not properly
            # handling pressed/unpressed state when this keybind overlaps with all the others.
            # Hacky workaround (but it still hangs) is to bind into the same key with the exact modifier.
            # REF; https://github.com/niri-wm/niri/issues/605
            "Mod+Space" = {
              _props = {
                hotkey-overlay-title = "Open app launcher";
                repeat = false;
              };
              spawn-sh = "noctalia msg panel-toggle launcher";
            };
            "Mod+L" = {
              _props = {
                hotkey-overlay-title = "Lock the Screen";
              };
              spawn = [
                "loginctl"
                "lock-session"
              ];
            };
            "Mod+Shift+E" = {
              _props = {
                hotkey-overlay-title = "Exit window manager";
              };
              # // The quit action will show a confirmation dialog to avoid accidental exits.
              quit = { };
            };
            # NOTE; Overlaps with shortcut that is caught/handled by systemd (??)
            "Ctrl+Alt+Delete" = {
              _props = {
                hotkey-overlay-title = "Exit window manager";
              };
              quit = { };
            };

            # Example volume keys mappings for PipeWire & WirePlumber.
            # The allow-when-locked=true property makes them work even when the session is locked.
            # Using spawn-sh allows to pass multiple arguments together with the command.
            # "-l 1.0" limits the volume to 100%.
            "XF86AudioRaiseVolume" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
            };
            "XF86AudioLowerVolume" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            };
            "XF86AudioMute" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            };
            "XF86AudioMicMute" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            };

            # Example media keys mapping using playerctl.
            # This will work with any MPRIS-enabled media player.
            "XF86AudioPlay" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "playerctl play-pause";
            };
            "XF86AudioPause" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "playerctl play-pause";
            };
            "XF86AudioStop" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "playerctl stop";
            };
            "XF86AudioPrev" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "playerctl previous";
            };
            "XF86AudioNext" = {
              _props = {
                allow-when-locked = true;
              };
              spawn-sh = "playerctl next";
            };

            # Example brightness key mappings for brightnessctl.
            # You can use regular spawn with multiple arguments too (to avoid going through "sh"),
            # but you need to manually put each argument in separate "" quotes.
            "XF86MonBrightnessUp" = {
              _props = {
                allow-when-locked = true;
              };
              spawn = [
                "brightnessctl"
                "--class=backlight"
                "set"
                "+10%"
              ];
            };
            "XF86MonBrightnessDown" = {
              _props = {
                allow-when-locked = true;
              };
              spawn = [
                "brightnessctl"
                "--class=backlight"
                "set"
                "10%-"
              ];
            };

            # Open/close the Overview: a zoomed-out view of workspaces and windows.
            # You can also move the mouse into the top-left hot corner,
            # or do a four-finger swipe up on a touchpad.
            "Mod+O" = {
              _props = {
                repeat = false;
              };
              toggle-overview = { };
            };

            "Mod+Q" = {
              _props = {
                repeat = false;
              };
              close-window = { };
            };

            "Mod+Left".focus-column-left = { };
            "Mod+Down".focus-window-down = { };
            "Mod+Up".focus-window-up = { };
            "Mod+Right".focus-column-right = { };

            "Mod+Ctrl+Left".move-column-left = { };
            "Mod+Ctrl+Down".move-window-down = { };
            "Mod+Ctrl+Up".move-window-up = { };
            "Mod+Ctrl+Right".move-column-right = { };

            # Mod+Home { focus-column-first; }
            # Mod+End  { focus-column-last; }
            # Mod+Ctrl+Home { move-column-to-first; }
            # Mod+Ctrl+End  { move-column-to-last; }

            # Mod+Shift+Left  { focus-monitor-left; }
            # Mod+Shift+Down  { focus-monitor-down; }
            # Mod+Shift+Up    { focus-monitor-up; }
            # Mod+Shift+Right { focus-monitor-right; }

            # Move the whole workspace to another monitor
            "Mod+Shift+Ctrl+Left".move-workspace-to-monitor-left = { };
            "Mod+Shift+Ctrl+Down".move-workspace-to-monitor-down = { };
            "Mod+Shift+Ctrl+Up".move-workspace-to-monitor-up = { };
            "Mod+Shift+Ctrl+Right".move-workspace-to-monitor-right = { };

            "Mod+Page_Down".focus-workspace-down = { };
            "Mod+Page_Up".focus-workspace-up = { };
            "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
            "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };

            # // Alternatively, there are commands to move just a single window:
            # // Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
            # // ...

            # Mod+Shift+Page_Down { move-workspace-down; }
            # Mod+Shift+Page_Up   { move-workspace-up; }
            # Mod+Shift+U         { move-workspace-down; }
            # Mod+Shift+I         { move-workspace-up; }

            # // You can bind mouse wheel scroll ticks using the following syntax.
            # // These binds will change direction based on the natural-scroll setting.
            # //
            # // To avoid scrolling through workspaces really fast, you can use
            # // the cooldown-ms property. The bind will be rate-limited to this value.
            # // You can set a cooldown on any bind, but it's most useful for the wheel.
            # Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
            # Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
            # Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
            # Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

            # Mod+WheelScrollRight      { focus-column-right; }
            # Mod+WheelScrollLeft       { focus-column-left; }
            # Mod+Ctrl+WheelScrollRight { move-column-right; }
            # Mod+Ctrl+WheelScrollLeft  { move-column-left; }

            # // Usually scrolling up and down with Shift in applications results in
            # // horizontal scrolling; these binds replicate that.
            # Mod+Shift+WheelScrollDown      { focus-column-right; }
            # Mod+Shift+WheelScrollUp        { focus-column-left; }
            # Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
            # Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

            # Switches focus between the current and the previous workspace.
            "Mod+Tab".focus-workspace-previous = { };

            # // The following binds move the focused window in and out of a column.
            # // If the window is alone, they will consume it into the nearby column to the side.
            # // If the window is already in a column, they will expel it out.
            # Mod+BracketLeft  { consume-or-expel-window-left; }
            # Mod+BracketRight { consume-or-expel-window-right; }

            # Consume one window from the right to the bottom of the focused column.
            "Mod+Comma".consume-window-into-column = { };
            # Expel the bottom window from the focused column to the right.
            "Mod+Period".expel-window-from-column = { };

            # // Cycle through widths set in preset-column-widths.
            # Mod+R { switch-preset-column-width; }
            # // Cycling through the presets in reverse order is also possible.
            # Mod+Shift+R { switch-preset-column-width-back; }

            # Mod+Ctrl+Shift+R { switch-preset-window-height; }
            # Mod+Ctrl+R { reset-window-height; }

            "Mod+F".maximize-column = { };
            "Mod+Shift+F".fullscreen-window = { };

            # // While maximize-column leaves gaps and borders around the window,
            # // maximize-window-to-edges doesn't: the window expands to the edges of the screen.
            # // This bind corresponds to normal window maximizing,
            # // e.g. by double-clicking on the titlebar.
            # Mod+M { maximize-window-to-edges; }

            # // Expand the focused column to space not taken up by other fully visible columns.
            # // Makes the column "fill the rest of the space".
            "Mod+Ctrl+F".expand-column-to-available-width = { };

            "Mod+C".center-column = { };

            # Center all fully visible columns on screen.
            "Mod+Ctrl+C".center-visible-columns = { };

            # // Finer width adjustments.
            # // This command can also:
            # // * set width in pixels: "1000"
            # // * adjust width in pixels: "-5" or "+5"
            # // * set width as a percentage of screen width: "25%"
            # // * adjust width as a percentage of screen width: "-10%" or "+10%"
            # // Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
            # // set-column-width "100" will make the column occupy 200 physical screen pixels.
            "Mod+Minus".set-column-width = "-10%";
            "Mod+Equal".set-column-width = "+10%";

            # // Finer height adjustments when in column with other windows.
            # Mod+Shift+Minus { set-window-height "-10%"; }
            # Mod+Shift+Equal { set-window-height "+10%"; }

            # Move the focused window between the floating and the tiling layout.
            "Mod+V".toggle-window-floating = { };
            "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };

            # // Toggle tabbed column display mode.
            # // Windows in this column will appear as vertical tabs,
            # // rather than stacked on top of each other.
            # Mod+W { toggle-column-tabbed-display; }

            # // Actions to switch layouts.
            # // Note: if you uncomment these, make sure you do NOT have
            # // a matching layout switch hotkey configured in xkb options above.
            # // Having both at once on the same hotkey will break the switching,
            # // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
            # // Mod+Space       { switch-layout "next"; }
            # // Mod+Shift+Space { switch-layout "prev"; }

            "Print".screenshot = { };
            "Ctrl+Print".screenshot-screen = { };
            "Alt+Print".screenshot-window = { };

            # // Applications such as remote-desktop clients and software KVM switches may
            # // request that niri stops processing the keyboard shortcuts defined here
            # // so they may, for example, forward the key presses as-is to a remote machine.
            # // It's a good idea to bind an escape hatch to toggle the inhibitor,
            # // so a buggy application can't hold your session hostage.
            # //
            # // The allow-inhibiting=false property can be applied to other binds as well,
            # // which ensures niri always processes them, even when an inhibitor is active.
            "Mod+Escape" = {
              _props = {
                allow-inhibiting = false;
              };
              toggle-keyboard-shortcuts-inhibit = { };
            };

            # // Powers off the monitors. To turn them back on, do any input like
            # // moving the mouse or pressing any other key.
            # Mod+Shift+P { power-off-monitors; }

            # Niri has no builtin screen mirroring, so use a 3rd party tool to create a mirror of
            # another window eg,
            #
            # 1. Focus the output you want to mirror, press Mod+P and move the wl-mirror window to the target output.
            # 2. Finally, fullscreen the wl-mirror window pressing Mod+Shift+F.
            "Mod+P" = {
              _props.repeat = false;
              spawn-sh = "wl-mirror $(niri msg --json focused-output | jq -r .name)";
            };
          };
        };
      };

      programs.noctalia = {
        enable = true;
        # WARN; NOT using nixpkgs upstream package will cause the buildhost to compile Noctalia!
        package = pkgs.noctalia;
        systemd.enable = true;
        validateConfig = true;
        settings = {
          shell = {
            font_family = "Montserrat SemiBold";
            settings_show_advanced = true;
            launch_apps_as_systemd_services = true;
            polkit_agent = true;
            screen_time_enabled = true;

            panel.session_placement = "floating";
            panel.transparency_mode = "soft";

            # Why is this default true, WTF??
            launcher.fetch_exchange_rates = false;
          };

          theme = {
            mode = "dark";
            source = "wallpaper";
            wallpaper_scheme = "faithful";
            templates.builtin_ids = [
              "alacritty"
              "niri"
            ];
          };

          dock = {
            enabled = true;
            active_monitor_only = true;
            magnification = false;
            reserve_space = false;
            smart_auto_hide = true;
            icon_size = 32;
            show_running = false;
            launcher_position = "start";
            launcher_icon = "topology-ring-2";
            pinned = [
              "firefox"
              "codium"
              "alacritty"
            ];
          };

          bar = {
            # Only need one icon bar
            order = [ "default" ];
            default = {
              enabled = true;
              reserve_space = false;
              position = "right";
              smart_auto_hide = true;
              dead_zone.actions.left = "bar-hide";
              start = [
                "notifications"
                "clock"
              ];
              center = [
                "output_volume"
                "brightness"
                "network"
                "battery"
              ];
              end = [ "session" ];
            };
          };

          widget = {
            bluetooth.enabled = false;
            clipboard.enabled = false;
            launcher.enabled = false;
            media.enabled = false;
            wallpaper.enabled = false;
            workspaces.enabled = false;
          };

          control_center = {
            hidden_tabs = [
              # "notifications" # turns out notification history is useful
              # "system" # show cpu/ram/network metrics
              "media"
              "weather"
              "calendar"
            ];
            sidebar = "full";
          };

          backdrop = {
            enabled = true;
            blur_intensity = 0.5; # 0.0 = no blur, 1.0 = maximum blur
            tint_intensity = 0.3; # 0.0 = no tint, 1.0 = fully opaque tint
          };

          idle = {
            # Use Noctalia builtin idle handling (instead of swayidle/other wayland tracker)
            behavior_order = [
              "inform"
              "lock"
              "screen-off"
              "suspend"
            ];
            # NOTE; This triggers before _every_ configured behavior!
            pre_action_fade_seconds = 0;
            behavior.inform = {
              enabled = true;
              timeout = 285; # Seconds
              action = "command";
              command = "notify-send --app-name 'Idle watcher' --expire-time 15000 --transient 'Idle' 'Going idle in 15s'";
            };
            behavior.lock = {
              enabled = true;
              timeout = 300; # Seconds
              action = "lock"; # builtin action, lock session
            };
            behavior.screen-off = {
              enabled = true;
              timeout = 330; # Seconds
              action = "screen_off"; # builtin, turns monitors off and back on when you return
            };
            behavior.suspend = {
              enabled = true;
              timeout = 600; # Seconds
              # or action = "suspend" with lock_before_suspend = false
              action = "lock_and_suspend"; # builtin, suspends the system
            };
          };

          lockscreen_widgets = {
            enabled = true;
            schema_version = 2;
            grid = {
              cell_size = 8;
              major_interval = 4;
              visible = true;
            };
            widget_order = [
              "lockscreen-login-box@eDP-1"
              "lockscreen-widget-clock"
            ];
            widget."lockscreen-widget-clock" = {
              type = "clock";
              box_height = 192.0;
              box_width = 384.0;
              cx = 768.0;
              cy = 256.0;

              settings = {
                background = false;
                center_text = true;
              };
            };
          };
        };
      };

      programs.nushell.enable = true;

      programs.firefox = {
        enable = true;
        package = osConfig.programs.firefox.finalPackage;

        policies = {
          # Updates & Background Services
          AppAutoUpdate = false;
          BackgroundAppUpdate = false;

          # Feature Disabling
          DisableBuiltinPDFViewer = true;
          DisableFirefoxStudies = true;
          DisableFirefoxAccounts = true;
          DisableFirefoxScreenshots = true;
          DisableForgetButton = true;
          DisableMasterPasswordCreation = true;
          DisableProfileImport = true;
          DisableProfileRefresh = true;
          DisableSetDesktopBackground = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFormHistory = true;
          DisablePasswordReveal = true;

          # Access Restrictions
          BlockAboutConfig = false;
          BlockAboutProfiles = true;
          BlockAboutSupport = true;

          # UI and Behavior
          DisplayMenuBar = "never";
          DontCheckDefaultBrowser = true;
          HardwareAcceleration = true;
          OfferToSaveLogins = false;
          DefaultDownloadDirectory = config.xdg.userDirs.download;

          # Extensions
          ExtensionSettings =
            let
              moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
            in
            {
              "*".installation_mode = "blocked";

              "uBlock0@raymondhill.net" = {
                install_url = moz "ublock-origin";
                installation_mode = "force_installed";
                updates_disabled = false;
                default_area = "menupanel";
                private_browsing = true;
              };

              # TODO; Bitwarden
              # TODO; Consent-o-matic
              # TODO; Treestyle tabs
              # TODO; BE-ID
            };

          # Extension configuration
          "3rdparty".Extensions = {
            "uBlock0@raymondhill.net".adminSettings = {
              userSettings = {
                # cloudStorageEnabled = mkForce false;

                # importedLists = [
                #   "https:#filters.adtidy.org/extension/ublock/filters/3.txt"
                #   "https:#github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
                # ];

                # externalLists = lib.concatStringsSep "\n" importedLists;
              };

              selectedFilterLists = [
                "user-filters"
                "ublock-filters"
                "ublock-badware"
                "ublock-privacy"
                "ublock-quick-fixes"
                "ublock-unbreak"
                "easylist"
                "easyprivacy"
                "urlhaus-1"
                "plowe-0"
                "fanboy-cookiemonster"
                "ublock-cookies-easylist"
              ];
            };
          };
        };

        profiles.default.search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";

          # NOTE; I'm using bookmarks with shortcuts as search engine. Those sync between devices
          # engines = {};
        };
      };
    };
}
