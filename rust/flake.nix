{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
    }:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      buildPackage =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          fenixPkgs = fenix.packages.${system};
        in
        pkgs.mkShell {
          buildInputs = [
            (fenixPkgs.stable.withComponents [
              "cargo"
              "rustc"
              "clippy"
              "rustfmt"
            ])
            pkgs.valgrind
          ];
        };

    in
    {
      devShell = forAllSystems buildPackage;
    };
}
