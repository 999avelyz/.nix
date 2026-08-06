{ config, ... }:

{
  # Drives.nix (nixos-generate-config output, not to be edited) leaves
  # swapDevices empty, so this machine ran with zero swap on 30GB of RAM.
  # With nowhere to put cold anonymous pages the kernel reclaims file-backed
  # ones instead — the game executable, the .pak files, the DXVK shader cache —
  # and then faults them straight back off btrfs. That thrash loop is what the
  # multi-minute freezes were, and it runs until the OOM killer finally fires:
  #
  #   Aug 06 21:09:20 kernel: kswapd0 invoked oom-killer: ... global_oom
  #   Aug 06 21:09:20 kernel: Out of memory: Killed process 2067 (electron)
  #
  # systemd-oomd is active but the kernel killer got there first, so it wasn't
  # providing cover. zram gives reclaim a fast destination that never touches
  # the disk; at ~2-3:1 zstd ratios 50% nominal is roughly 30-45GB of effective
  # headroom, which comfortably covers Dead by Daylight plus a browser and
  # Discord.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Tuning for a zram-only setup (no disk swap anywhere in the config).
  #
  # swappiness: the 60 default is calibrated for swap that costs a disk seek.
  # Compressed RAM is orders of magnitude cheaper than re-reading a page off
  # btrfs, so anonymous memory should be the *preferred* reclaim target rather
  # than the last resort. 180 is the value CachyOS/Fedora/ChromeOS settled on
  # for zram (the ceiling is 200 since 5.8).
  #
  # page-cluster: swapin readahead pulls 2^3 = 8 pages per fault by default to
  # amortise seeks. There are no seeks here, so it just burns decompression
  # cycles on pages nothing asked for. 0 = fault in one page at a time.
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
  };
}
