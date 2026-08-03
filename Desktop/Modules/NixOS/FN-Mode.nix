{ config, pkgs, ... }:

{
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  boot.kernelModules = [ "hid_apple" ];

  system.activationScripts.hidAppleFnmode = ''
    if [ -e /sys/module/hid_apple/parameters/fnmode ]; then
      echo 2 > /sys/module/hid_apple/parameters/fnmode
    fi
  '';
}
