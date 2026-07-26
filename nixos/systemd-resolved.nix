{ ... }: {
  services.resolved = {
    enable = true;
    settings.Resolve = {
      # Disabled in favour of mDNS
      LLMNR = false;
      # mDNS responder and resolver
      MulticastDNS = true;
      Domains = [ "~." ];
    };
  };
}
