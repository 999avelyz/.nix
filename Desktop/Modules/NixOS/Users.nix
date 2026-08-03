{ config, ... }:

{
  users.users."denis" = {
    isNormalUser = true;
    description = "Denis";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
