{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    fenix = {
      url = "github:nix-community/fenix/monthly";
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

          llvm = pkgs.llvmPackages_latest;

          llvmStdenv = pkgs.overrideCC llvm.libcxxStdenv (
            llvm.libcxxStdenv.cc.override {
              inherit (llvm) bintools;
            }
          );

          fenixPkgs = fenix.packages.${system};
        in
        pkgs.mkShell.override { stdenv = llvmStdenv; } {
          buildInputs = [
            (fenixPkgs.latest.withComponents [
              "cargo"
              "rustc"
              "clippy"
              "rustfmt"
              "miri"
            ])
            pkgs.valgrind
          ];
        };
    in
    {
      devShells = forAllSystems (system: {
        default = buildPackage system;
      });
    };
}
