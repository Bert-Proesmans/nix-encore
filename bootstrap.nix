{
  modulesPath,
  lib,
  config,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./nixos/internationalisation.nix
    ./nixos/nix.nix
    ./nixos/systemd-dnssd.nix
    ./nixos/systemd-resolved.nix
  ];

  config = {
    boot.initrd.systemd.emergencyAccess = true;
    # Enables (nested) virtualization through hardware acceleration.
    # There is no harm in having both modules loaded at the same time, also no real overhead.
    boot.kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];
    # enable zswap to help with low memory systems
    boot.kernelParams = [
      "zswap.enabled=1"
      "zswap.max_pool_percent=50"
      "zswap.compressor=zstd"
      # recommended for systems with little memory
      "zswap.zpool=zsmalloc"
    ];
    boot.zfs.forceImportRoot = false; # Silence warning about unsafe default

    # Minimal-installer (useful for mDNS)
    networking.hostName = lib.mkForce "minstaller";
    nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";
    system.stateVersion = lib.mkForce config.system.nixos.release;

    # Ensure sshd works
    systemd.services.sshd.wantedBy = [ "multi-user.target" ];
    users.users.nixos.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOs8kDMMm/QFeELt79EG9akdfX7dlfRuTezwVEqbPsM bert@B-PC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEeQ/KEIWbUKBc4bhZBUHsBB0yJVZmBuln8oSVrtcA5 bert@B-PC"
    ];
    systemd.dnssd.services = {
      ssh = {
        hostname = "%H";
        type = "_ssh._tcp";
        port = 22;
      };
    };

    # Make the image as small as possible #
    isoImage.storeContents = [ ];

    networking.wireless.enable = lib.mkForce false;
    documentation.enable = lib.mkForce false;
    documentation.nixos.enable = lib.mkForce false;
    documentation.man.man-db.enable = lib.mkForce false;

    # Drop ~400MB firmware blobs from nix/store, but this will make the host not boot on bare-metal!
    hardware.enableRedistributableFirmware = lib.mkForce false;

    # ERROR; The mkForce is required to _reset_ the lists to empty! While the default
    # behaviour is to make a union of all list components!
    # No GCC toolchain
    system.extraDependencies = lib.mkForce [ ];
    # Remove default packages not required for a bootable system
    environment.defaultPackages = lib.mkForce [ ];
    # prevents shipping nixpkgs, unnecessary if system is evaluated externally
    nix.registry = lib.mkForce { };

    # Remove references to Filesystem Hierarchy Standard (FHS) compatibility shims, this makes FHS at runtime impossible
    environment.ldso = lib.mkForce null;
    environment.ldso32 = lib.mkForce null;

    # Faster and (almost) equally as good compression
    isoImage.squashfsCompression = lib.mkForce "zstd -Xcompression-level 15";
  };
}
