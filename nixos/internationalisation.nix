{ lib, ... }: {
  # Force be-latin keymap (= BE-AZERTY-ISO)
  services.xserver.xkb.layout = "be";
  services.xserver.xkb.variant = ""; # Explicitly empty!
  console.useXkbConfig = true;

  time.timeZone = lib.mkDefault "Etc/UTC";
}
