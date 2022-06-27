{
  description = "Nix System Configs for Workstations at the LUG Office";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
  };
  outputs = { nixpkgs, ...}:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in {
      nixosConfigurations."EVA" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./main.nix ];
      };
    };
}
