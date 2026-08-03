{ config, ... }:

{
  services = {
    xserver.enable = false;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  console.keyMap = "us";
}
