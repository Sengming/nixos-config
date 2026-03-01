{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    whisper-dictation.url = "github:jacopone/whisper-dictation";
  };

  outputs = { self, nixpkgs, whisper-dictation, ... }@inputs: {
    nixosConfigurations.sengming = nixpkgs.lib.nixosSystem {
      # optional but nice to be explicit
      system = "x86_64-linux";

      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
      ];
    };
  };
}
