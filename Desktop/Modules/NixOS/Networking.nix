{ config, ... }:

{
  networking = {
    hostName = "NixDesktop";
    wireless.enable = true;
    networkmanager.enable = true;
  };
}
