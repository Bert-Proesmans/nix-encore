{ lib, ... }: {
  # Force be-latin keymap (= BE-AZERTY-ISO)
  console.keyMap = "be-latin1";
  time.timeZone = lib.mkDefault "Etc/UTC";
}
