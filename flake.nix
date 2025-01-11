{
  description = "NixOS OpenStack image build configuration";
  inputs =  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      # configuration for builidng qcow2 images
      build-qcow2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./qcow2.nix
        ];
      };
    };
  };
}
