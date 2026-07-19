{ ... }: {
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-path/pci-0000:04:00.0-nvme-1";
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
              name = "crypted";
              extraOpenArgs = [ ];
              settings = {
                # if you want to use the key for interactive login be sure there is no trailing newline
                # for example use `echo -n "password" > /tmp/secret.key`
                keyFile = "/tmp/secret.key";
                allowDiscards = true; # optimized for ssd
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
