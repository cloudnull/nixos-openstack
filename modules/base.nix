# Core NixOS system configuration
{ config, lib, pkgs, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      options = [ "nofail" "x-systemd.device-timeout=5s" ];
    };
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  boot = {
    tmp.cleanOnBoot = true;
    growPartition = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "console=ttyS0" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.device = lib.mkDefault "/dev/vda";
    };
  };

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    wireless.enable = false;
  };

  systemd.network.enable = true;

  system = {
    stateVersion = "25.11";
    userActivationScripts.zshrc = "touch .zshrc";
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:cloudnull/nixos-openstack";
      flags = [
        "--update-input"
        "nixpkgs"
        "-L"
      ];
    };
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      nixos-rebuild-flake = "sudo nixos-rebuild switch --flake github:cloudnull/nixos-openstack";
    };
  };

  environment = {
    systemPackages = with pkgs; [
      htop
      tmux
      vim-full
      zsh
    ];
    variables.EDITOR = "vim";
  };

  security.sudo.wheelNeedsPassword = false;
}
