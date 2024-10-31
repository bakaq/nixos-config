# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8ac8fe1e-7876-457d-a39d-3436a540de3a";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/8ac8fe1e-7876-457d-a39d-3436a540de3a";
      fsType = "btrfs";
      options = [ "subvol=local/nix" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/8ac8fe1e-7876-457d-a39d-3436a540de3a";
      fsType = "btrfs";
      options = [ "subvol=safe/home" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/8ac8fe1e-7876-457d-a39d-3436a540de3a";
      fsType = "btrfs";
      options = [ "subvol=local/swap" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/07E0-C852";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/slow-storage" =
    { device = "/dev/disk/by-uuid/3dbd091f-801a-4ad8-ad45-da2c17a08a51";
      fsType = "btrfs";
    };

  fileSystems."/home/kaue/games" =
    { device = "/dev/disk/by-uuid/8ac8fe1e-7876-457d-a39d-3436a540de3a";
      fsType = "btrfs";
      options = [ "subvol=local/games" ];
    };

  fileSystems."/fast-storage" =
    { device = "/dev/disk/by-uuid/8ac8fe1e-7876-457d-a39d-3436a540de3a";
      fsType = "btrfs";
      options = [ "subvol=safe/fast-storage" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
