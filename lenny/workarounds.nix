{ pkgs, ... }: {
  # Patch DBus to skip warning on repeated imports of service files under different paths
  # REF; https://github.com/NixOS/nixpkgs/issues/303078
  services.dbus = {
    brokerPackage = pkgs.dbus-broker.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./dbus-duplicate-service-log-extender.patch
      ];
    });
  };

  fileSystems = {
    "/nix" = {
      # NOTE; /nix attrset is completed by disko.

      # Disconnect the mount from fsck (systemd-fsck@%I.service).
      # Systemd filesystem check service has a Requires= on 'nix.mount', stopping ~'fsck.service' will propagate the stop
      # to 'nix.mount'through Requires relation. We don't want our /nix mount to be stopped!
      #
      # NOTE; systemd has hardcoded filters that prevent unmounting / (root) at shutdown, this should have
      # also applied to '/nix'. (final unmount could/should happen inside shutdown initramfs)
      #
      # NOREF
      noCheck = true;
    };
  };

  nixpkgs.overlays = [
    (final: previous: {
      # Append attributes to derivation so its wrapped with dependencies correctly eg, software encoding/hardware acceleration.
      # REF; https://github.com/NixOS/nixpkgs/pull/550150
      firefoxpwa-unwrapped = previous.firefoxpwa-unwrapped.overrideAttrs (old: {
        passthru = old.passthru // {
          inherit (final.firefox-unwrapped)
            ffmpegSupport
            gssSupport
            alsaSupport
            pipewireSupport
            sndioSupport
            jackSupport
            ;
        };
      });
    })
  ];
}
