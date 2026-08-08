{
  modulesPath,
  sources,
  lib,
  config,
  pkgs,
  ...
}:
{

  imports = [
    # TODO; Remove on completion of hardware config
    (modulesPath + "/installer/scan/not-detected.nix")
    (sources.nixos-hardware + "/lenovo/thinkpad/l14/intel")
    (sources.nixos-hardware + "/common/cpu/intel/meteor-lake")
    # (sources.nixos-hardware + "/lenovo/thinkpad/l14/amd")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.wirelessRegulatoryDatabase = true;
  # hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.graphics.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
        FastConnectable = true; # Lowers connection latency and helps with low-power device waking
      };
    };
  };

  # Hide the OS choice for bootloaders.
  # It's still possible to open the bootloader list by pressing any key
  # It will just not appear on screen unless a key is pressed
  boot.loader.timeout = 0;
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = false;

  # NOTE; During the graphical boot process, it is possible to switch to text mode and back by pressing the escape key!
  boot.plymouth = {
    enable = true;
    theme = "hexagon_dots_alt";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        # By default we would install all themes
        selected_themes = [ "hexagon_dots_alt" ];
      })
    ];
  };

  boot.tmp = {
    useZram = true;
    zramSettings.zram-size = "min(ram * 0.5, 4096)";
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = lib.mkForce false;
  boot.initrd.availableKernelModules = [
    # NOTE; PCI / Thunderbolt could listen for keystrokes and/or intercept the LUKS session key during initrd.
    "xhci_pci"
    "thunderbolt"
    "nvme"
    # NOTE; Not including any Intel Management Extension (IME) modules in initrd, this will cause errors thrown by the graphics driver
    # because it has a dependency on IME for Digital Rights Management (DRM) functionality. eg
    # i915 0000:00:02.0: [drm] *ERROR* GT1: GSC proxy component didn't bind within the expected timeout
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  disko.devices = {
    disk.main = {
      type = "disk";
      # Path compatible with Lenovo L14 Gen5 and L14 Gen6
      device = "/dev/disk/by-path/pci-0000:04:00.0-nvme-1";
      imageSize = "20G"; # Used in tests and verification
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          empty = {
            # Unused space to keep ssd write latency down
            size = "10G";
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              # Refer to this virtual block device by "/dev/mapper/crypted".
              # Partitions within are named "/dev/mapper/cryptedN" with N being 1-indexed partition counter
              name = "crypted";
              extraFormatArgs = [
                "--type luks2"
                "--hash sha256"
                "--pbkdf argon2i"
                # PBKDF is benchmarked towards iter-time and memory usage.
                "--iter-time 40000" # 4 seconds
                "--pbkdf-memory 4194304" # 4 gigabyte (iter-time has priority, this value is automatically lowered)
                # Best performance according to cryptsetup benchmark
                "--cipher aes-xts-plain64" # [cipher]-[mode]-[iv] format
                # WARN; Effective AES key-size is 128 (256 split in two due to xts)!
                # NOTE; I'm considering AES-128 (~126 bit randomness) secure with global (world) hashrate being less than
                # 2^81 hashes per second.
                "--key-size 256"
                "--use-urandom"
                # Samsung nvmes lie to the operating system for maximum backwards compatibility!
                #
                # # nvme id-ns /dev/nvme0n1 -H | grep "LBA Format"
                #   [6:5] : 0     Most significant 2 bits of Current LBA Format Selected
                #   [3:0] : 0     Least significant 4 bits of Current LBA Format Selected
                # LBA Format  0 : Metadata Size: 0   bytes - Data Size: 512 bytes - Relative Performance: 0 Best (in use)
                #
                # The missing LBA Format 1..N means the controller does not allow sector units larger than 512 bytes.
                # YET THE PHYSICAL SECTORS ARE PROBABLY 4-16K !! Still instruct LUKS to use 4K sectors to prevent write amplification.
                "--sector-size 4096" # 4K, LUKS does not support 16K
              ];
              extraOpenArgs = [ ];
              # If you want to use the key for interactive login be sure there is no trailing newline
              # for example use `echo -n "password" > /tmp/disk1.key`
              # NOTE; passwordFile != settings.keyFile, the latter is _also_ used for unlocking during initrd on the installed system
              passwordFile = "/tmp/disk1.key";
              settings = {
                allowDiscards = true; # optimized for ssd
                bypassWorkqueues = true; # optimized for ssd (no read/write batching in kernel)
              };
              content = {
                type = "lvm_pv";
                vg = "root";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      root = {
        type = "lvm_vg";
        lvs = {
          plainSwap = {
            size = "8G";
            content = {
              type = "swap";
              discardPolicy = "both"; # optimized for ssd
              resumeDevice = false; # no resume from hiberation
            };
          };
          nix = {
            # Separate partition to prevent inode exhaustion
            # WARN; Not picking lvm thinpool because that system damages itself when free physical space drops to zero.
            size = "60G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
              # NOTE; Nix boot stages and daemon remount parts of this partition at runtime!
              mountOptions = [
                "nosuid"
                "nodev"
                "noatime"
                # Make LUKS password entry timeout infinite
                "x-systemd.device-timeout=0"
              ];
            };
          };
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
                # Make LUKS password entry timeout infinite
                "x-systemd.device-timeout=0"
              ];
            };
          };
        };
      };
    };
  };

  services.fstrim.enable = true;
  services.logind.settings.Login = {
    # WARN; Even though logind has configuration for idle monitoring, that is currently not integrated!
    # Keyboard/mouse tracking is handled through swayidle.
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
  };

  # ERROR; Thermald automatically shuts down on start
  # => Lenovo laptops require thinkpad_acpi kernel driver that includes a dynamic thermal manager
  # HINT; Set 'services.power-profiles-daemon.enable' to true instead. (enabled by noctalia)
  services.thermald.enable = false;
  # TLP is incompatible with power-profiles-daemon, and too aggressive of a scaler.
  # WARN; Modern CPUs are built to race into sleep, capping their max performance gives marginal power gains and
  # non-lineair negative effects on performance.
  services.tlp.enable = false;

  systemd.tmpfiles.rules = [
    # Start charging at or below 75%
    "w /sys/class/power_supply/BAT0/charge_control_start_threshold - - - - 75"
    # Stop charging at or above 80%
    "w /sys/class/power_supply/BAT0/charge_control_end_threshold   - - - - 80"
  ];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "admin-force-battery-discharge";
      runtimeInputs = [ ];
      text = ''
        # Forces the battery controller to discharge the battery
        # - even though charging threshold isn't met
        # - even though the computer is connected to AC power

        BATTERY_DEV=/sys/class/power_supply/BAT0
        if [[ ! -r "$BATTERY_DEV/charge_behaviour" || ! -w "$BATTERY_DEV/charge_behaviour" ]]; then
          echo "Script must run as root to access battery controller"
          exit 1
        fi

        echo "force-discharge" > "$BATTERY_DEV/charge_behaviour"
        echo "Battery set to force-discharge mode."
      '';
    })
  ];

  systemd.sleep.settings.Sleep = {
    AllowSuspendThenHibernate = "yes";
    HibernateDelaySec = "30m";
  };
}
