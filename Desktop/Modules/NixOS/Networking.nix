{ config, ... }:

{
  networking = {
    hostName = "NixDesktop";
    wireless.enable = true;
    networkmanager.enable = true;

    # KDE Connect: discovery (UDP) + pairing/transfer (TCP)
    firewall.allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    firewall.allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];
  };
}
