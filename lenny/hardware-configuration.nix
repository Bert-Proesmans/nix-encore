{ modulesPath, config, ... }: {

  imports = [
    # TODO; Remove on completion of hardware config
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.graphics.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  # TODO; Is it necessary to edit EFI config while updating the system?
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp = {
    useZram = true;
    zramSettings.zram-size = "min(ram * 0.5, 4096)";
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  services.fstrim.enable = true;

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
                # PBKDF is benchmarked towards iter-time and memory usage. The defaults are increased!
                "--iter-time 10000" # 10 seconds
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
              settings = {
                # if you want to use the key for interactive login be sure there is no trailing newline
                # for example use `echo -n "password" > /tmp/disk1.key`
                keyFile = "/tmp/disk1.key";
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
              ];
            };
          };
        };
      };
    };
  };
}
