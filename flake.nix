{
  description = "dotfiles (Linux)";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixos-unstable` for the latest packages.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, home-manager, ... }:
    let
      user = "root";
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit user; };
        modules = [ ./home.nix ];
      };
    };
}
