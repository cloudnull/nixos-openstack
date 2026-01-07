# NixOS OpenStack image configuration
# Import all modules for a complete cloud-ready system
{ ... }: {
  imports = [
    ./modules/base.nix
    ./modules/cloud-init.nix
    ./modules/openstack.nix
  ];
}
