{ config, pkgs, ... }:

let
  # usbhid non si aggancia all'interfaccia dell'ODDOR handbrake (1021:1888)
  # su questo kernel: usb_driver_attach fallisce con -ENODEV, riproducibile
  # al 100% su porte/controller diversi, senza log kernel utili, e non e'
  # Steam Input (verificato con Steam completamente chiuso). Il device
  # risponde perfettamente via libusb raw, quindi bypassiamo usbhid con un
  # bridge userspace che espone un joystick virtuale via uinput.
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
      # Serve root: accesso raw a /dev/bus/usb/* (il device non ha driver
      # kernel quindi niente permessi via udev standard) e a /dev/uinput.
      User = "root";
    };
  };
}
