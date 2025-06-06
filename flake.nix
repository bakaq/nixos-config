{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    #nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      #nixpkgs-stable,
      musnix,
      ...
    }@inputs:
    {
      nixosConfigurations.kbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          musnix.nixosModules.musnix
          ./configuration.nix
        ];
        specialArgs = {
          inherit inputs;
          #pkgs-stable = import nixpkgs-stable { system = "x86_64-linux"; };
        };
      };
    };
}
