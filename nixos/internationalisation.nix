{ lib, ... }: {
  # Force be-latin keymap (= BE-AZERTY-ISO)
  services.xserver.xkb.layout = "be";
  services.xserver.xkb.variant = ""; # Explicitly empty!
  # NOTE; Make CAPSLOCK behave like on Windows, print numbers instead of uppercased special characters.
  services.xserver.xkb.options = "caps:digits_row";
  console.useXkbConfig = true;

  time.timeZone = lib.mkDefault "Etc/UTC";

  i18n = {
      defaultLocale = lib.mkDefault "en_GB.UTF-8";
      extraLocales = [
        "en_GB.UTF-8/UTF-8"
        "nl_BE.UTF-8/UTF-8"
      ];
      # REF; https://man.archlinux.org/man/locale.7
      extraLocaleSettings = {
        LC_NUMERIC = lib.mkDefault "nl_BE.UTF-8";
        LC_TIME = lib.mkDefault "nl_BE.UTF-8";
        LC_MONETARY = lib.mkDefault "nl_BE.UTF-8";
        LC_PAPER = lib.mkDefault "nl_BE.UTF-8";
        LC_NAME = lib.mkDefault "nl_BE.UTF-8";
        LC_ADDRESS = lib.mkDefault "nl_BE.UTF-8";
        LC_TELEPHONE = lib.mkDefault "nl_BE.UTF-8";
        LC_MEASUREMENT = lib.mkDefault "nl_BE.UTF-8";
        LC_IDENTIFICATION = lib.mkDefault "nl_BE.UTF-8";
      };
    };
}
