{
  description = "NixOS OpenStack image build configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # Formatter for nix fmt
    formatter.${system} = pkgs.nixfmt-rfc-style;

    # Reusable module for other flakes
    nixosModules.default = import ./configuration.nix;

    # NixOS configuration for building qcow2 images
    nixosConfigurations.build-qcow2 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        ./formats/qcow2.nix
      ];
    };

    # Convenience package output: nix build .#default
    packages.${system}.default =
      self.nixosConfigurations.build-qcow2.config.system.build.qcow2;
  };
}
