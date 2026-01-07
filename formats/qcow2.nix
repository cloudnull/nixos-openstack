# QCOW2 image format builder
{ config, lib, pkgs, modulesPath, ... }: {
  system.build.qcow2 = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    name = "nixos";
    format = "qcow2-compressed";
    partitionTableType = "efi";
    copyChannel = true;
    configFile = pkgs.writeText "configuration.nix" (pkgs.lib.readFile ../configuration.nix);
  };
}
