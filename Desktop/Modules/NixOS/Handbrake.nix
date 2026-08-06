{ config, pkgs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pyusb ps.evdev ]);
in
{
  systemd.services.handbrake-bridge = {
    description = "Bridge USB->uinput per ODDOR Handbrake (1021:1888)";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pythonEnv}/bin/python3 ${../../Scripts/HandbrakeBridge.py}";
      Restart = "always";
      RestartSec = 2;
      User = "root";
    };
  };
}
