{
  description = "Env for building Koka bencmarks";
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs.url = "nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packageName = "Koka benchmarks";
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            hyperfine
            cmake
            stack (haskellPackages.ghcWithPackages (p: [p.parallel]))
            koka
            ocaml
            jdk
            swift
          ];
        };
      }
    );
}
