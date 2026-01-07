# OpenStack and QEMU guest configuration
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  services = {
    resolved = {
      enable = true;
      dnssec = "false";
    };
    openssh.enable = true;
    qemuGuest.enable = true;
  };
}
