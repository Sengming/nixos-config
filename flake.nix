{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    whisper-dictation.url = "github:jacopone/whisper-dictation";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, whisper-dictation, home-manager, ... }@inputs: {
    nixosConfigurations.sengming = nixpkgs.lib.nixosSystem {
      # optional but nice to be explicit
      system = "x86_64-linux";

      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
