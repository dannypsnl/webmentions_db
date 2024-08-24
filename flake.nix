{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        webmentions_db = pkgs.beamPackages.mixRelease {
          pname = "webmentions_db";
          version = "0.1.0";
          src = ./.;
          removeCookie = false;
          mixNixDeps = with pkgs; import ./deps.nix {
            inherit lib beamPackages;
          };
        };
      in
      with pkgs; rec {
        packages = { webmentions_db = webmentions_db; };
        packages.default = packages.webmentions_db;
        devShells.default = mkShell {
          buildInputs = with pkgs; [
            # tools
            elixir
            mix2nix
          ];
        };
      });
}
