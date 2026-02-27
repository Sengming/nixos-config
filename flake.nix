{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.sengming = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}
