{ ... }: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.connect-timeout = 5;
  nix.settings.log-lines = 25;
}
