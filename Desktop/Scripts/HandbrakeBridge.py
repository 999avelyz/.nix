#!/usr/bin/env python3
"""
Bridge userspace per ZSC ODDOR-HANDBRAKE (1021:1888).
Il driver kernel usbhid non si aggancia a questo device su questo kernel
(usbhid_probe restituisce -ENODEV senza log, causa non identificata), ma
il device risponde correttamente via libusb raw. Questo daemon legge
l'endpoint interrupt IN e crea un joystick virtuale via uinput, che il
kernel (e quindi Wine/Proton/Assetto Corsa) vede come un normale joystick.

Report IN (5 byte, dal Report Descriptor letto via `lsusb -v`):
  byte0: bit0-2 = 3 bottoni, bit3-7 = padding
  byte1-2: asse 1, uint16 little-endian, range 0-32767
  byte3-4: asse 2, uint16 little-endian, range 0-32767

Gira in loop permanente: se il device non e' collegato o si disconnette,
riprova ogni 2 secondi invece di uscire, cosi' il systemd service resta
sempre pronto senza bisogno di essere ri-triggerato.
"""

import struct
import sys
import time

import usb.core
import usb.util
from evdev import UInput, ecodes, AbsInfo

VENDOR_ID = 0x1021
PRODUCT_ID = 0x1888
EP_IN = 0x81
READ_SIZE = 64
RETRY_DELAY = 2


def log(msg):
    print(msg, flush=True)


def find_device():
    return usb.core.find(idVendor=VENDOR_ID, idProduct=PRODUCT_ID)


def run_once():
    dev = find_device()
    if dev is None:
        return False

    try:
        if dev.is_kernel_driver_active(0):
            dev.detach_kernel_driver(0)
    except (NotImplementedError, usb.core.USBError):
        pass

    dev.set_configuration()
    usb.util.claim_interface(dev, 0)

    capabilities = {
        ecodes.EV_KEY: [ecodes.BTN_TRIGGER, ecodes.BTN_THUMB, ecodes.BTN_THUMB2],
        ecodes.EV_ABS: [
            (ecodes.ABS_X, AbsInfo(value=0, min=0, max=32767, fuzz=0, flat=0, resolution=0)),
            (ecodes.ABS_Y, AbsInfo(value=0, min=0, max=32767, fuzz=0, flat=0, resolution=0)),
        ],
    }

    ui = UInput(capabilities, name="ODDOR Handbrake (bridge)", vendor=VENDOR_ID, product=PRODUCT_ID)
    log(f"[handbrake-bridge] device trovato, joystick virtuale creato: {ui.device.path}")

    buttons = [ecodes.BTN_TRIGGER, ecodes.BTN_THUMB, ecodes.BTN_THUMB2]
    last_btn_state = [0, 0, 0]

    try:
        while True:
            try:
                data = dev.read(EP_IN, READ_SIZE, timeout=2000)
            except usb.core.USBError as e:
                if e.errno == 110:  # timeout: normale se il device non manda nulla di nuovo
                    continue
                log(f"[handbrake-bridge] device disconnesso o errore USB ({e}), riprovo tra {RETRY_DELAY}s")
                return True  # segnala al caller di ri-cercare il device

            if len(data) < 5:
                continue

            btn_byte, axis1, axis2 = struct.unpack_from("<BHH", bytes(data), 0)

            for i in range(3):
                state = (btn_byte >> i) & 1
                if state != last_btn_state[i]:
                    ui.write(ecodes.EV_KEY, buttons[i], state)
                    last_btn_state[i] = state

            ui.write(ecodes.EV_ABS, ecodes.ABS_X, axis1)
            ui.write(ecodes.EV_ABS, ecodes.ABS_Y, axis2)
            ui.syn()
    finally:
        try:
            usb.util.release_interface(dev, 0)
        except usb.core.USBError:
            pass
        ui.close()


def main():
    log("[handbrake-bridge] avviato, in attesa del device 1021:1888...")
    while True:
        try:
            found = run_once()
            if not found:
                time.sleep(RETRY_DELAY)
        except Exception as e:
            log(f"[handbrake-bridge] errore inatteso: {e}")
            time.sleep(RETRY_DELAY)


if __name__ == "__main__":
    main()
