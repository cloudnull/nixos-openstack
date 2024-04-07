{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];
  nix = {
    settings = {
      auto-optimise-store = true;
    };
  };
  fileSystems = {
    "/boot" = {
      label = "esp";
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
    "/" = {
      label = "nixos";
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };
  boot = {
    tmp = {
      cleanOnBoot = true;
    };
    growPartition = true;
    loader = {
      systemd-boot = {
        enable = true;
      };
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        device = lib.mkDefault "/dev/vda";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["console=ttyS0"];
  };
  networking = {
    useDHCP = false;
    dhcpcd = {
      enable = false;
    };
    wireless = {
      enable = false;
    };
  };
  systemd = {
    network = {
      enable = true;
    };
  };
  system = {
    stateVersion = "24.05";
    userActivationScripts = {
      zshrc = "touch .zshrc";
    };
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L"
      ];
    };
  };
  users.users = {
    nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
    };
    shellAliases = {
      ll = "ls -l";
    };
  };
  environment = {
    systemPackages = with pkgs; [
      htop
      tmux
      vim-full
      zsh
    ];
    variables = {
      EDITOR = "vim";
    };
  };
  security = {
    sudo = {
      wheelNeedsPassword = false;
    };
  };
  services = {
    resolved = {
      enable = true;
      dnssec = "false";
    };
    openssh = {
      enable = true;
    };
    qemuGuest = {
      enable = true;
    };
    cloud-init = {
      enable = true;
      network = {
        enable = true;
      };
      config = ''
        _log:
        - &log_base |
          [loggers]
          keys=root,cloudinit
          [handlers]
          keys=consoleHandler,cloudLogHandler
          [formatters]
          keys=simpleFormatter,arg0Formatter
          [logger_root]
          level=DEBUG
          handlers=consoleHandler,cloudLogHandler
          [logger_cloudinit]
          level=DEBUG
          qualname=cloudinit
          handlers=
          propagate=1
          [handler_consoleHandler]
          class=StreamHandler
          level=WARNING
          formatter=arg0Formatter
          args=(sys.stderr,)
          [formatter_arg0Formatter]
          format=%(asctime)s - %(filename)s[%(levelname)s]: %(message)s
          [formatter_simpleFormatter]
          format=[CLOUDINIT] %(filename)s[%(levelname)s]: %(message)s
        - &log_file |
          [handler_cloudLogHandler]
          class=FileHandler
          level=DEBUG
          formatter=arg0Formatter
          args=('/var/log/cloud-init.log', 'a', 'UTF-8')
        - &log_syslog |
          [handler_cloudLogHandler]
          class=handlers.SysLogHandler
          level=DEBUG
          formatter=simpleFormatter
          args=("/dev/log", handlers.SysLogHandler.LOG_USER)
        log_cfgs:
        - [ *log_base, *log_file ]
        manage_etc_hosts: false
        mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
        output: {all: '> /var/log/cloud-init-output.log'}
        # System and/or distro specific settings
        # (not accessible to handlers/transforms)
        system_info:
          # This will affect which distro class gets used
          distro: nixos
          network:
            renderers:
            - networkd
          # Default user name + that default users groups (if added/used)
          default_user:
            name: nixos
            lock_passwd: True
            gecos: NixOS
            groups:
            - wheel
            - cdrom
            - netdev
            - sudo
            sudo:
            - "ALL=(ALL) NOPASSWD:ALL"
            shell: /bin/zsh
          # Other config here will be given to the distro class and/or path classes
          paths:
            cloud_dir: /var/lib/cloud/
            templates_dir: /etc/cloud/templates/
          package_mirrors: []
          ssh_svcname: ssh
        ssh_pwauth: false
        chpasswd:
          expire: false
        # The top level settings are used as module
        # and system configuration.
        # A set of users which may be applied and/or used by various modules
        # when a 'default' entry is found it will reference the 'default_user'
        # from the distro configuration specified below
        users:
        - default
        # If this is set, 'root' will not be able to ssh in and they
        # will get a message to login instead as the above $user (nixos)
        disable_root: true
        # This will cause the set+update hostname module to not operate (if true)
        preserve_hostname: false
        # The modules that run in the 'init' stage
        cloud_init_modules:
        - migrator
        - seed_random
        - bootcmd
        - write-files
        - growpart
        - resizefs
        - disk_setup
        - mounts
        - set_hostname
        - update_hostname
        - update_etc_hosts
        - ca-certs
        - rsyslog
        - users-groups
        - ssh
        # The modules that run in the 'config' stage
        # Emit the cloud config ready event
        # this can be used by upstart jobs for 'start on cloud-config'.
        cloud_config_modules:
        - ssh-import-id
        - ntp
        - timezone
        - disable-ec2-metadata
        - runcmd
        - byobu
        # The modules that run in the 'final' stage
        cloud_final_modules:
        - scripts-vendor
        - scripts-per-once
        - scripts-per-boot
        - scripts-per-instance
        - scripts-user
        - ssh-authkey-fingerprints
        - keys-to-console
        - final-message
        - power-state-change
        '';
    };
  };
}
