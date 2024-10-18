{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    denoMap = {
      x86_64-linux = {
        name = "deno-x86_64-unknown-linux-gnu.zip";
        hash = "sha256-WQ4B0sT3qTVl4/Moj0FcFg5LDZIBPbnmcfUxwrmFyYY=";
      };
      aarch64-linux = {
        name = "deno-aarch64-unknown-linux-gnu.zip";
        hash = "sha256-a4jQ2fp7QHEt36qNrDECEfyfoqs2Qns5xxIkY9g+Oi0=";
      };
      x86_64-darwin = {
        name = "deno-x86_64-apple-darwin.zip";
        hash = "sha256-2Ld+ln6KM8m2x+yosiuNLRXjTUro6pyYUk12/R3SV64=";
      };
      aarch64-darwin = {
        name = "deno-aarch64-apple-darwin.zip";
        hash = "sha256-03fJO1fbunRBmdKrQYt9VdNhYetGvf/xwrn+EneoARI=";
      };
    };
    denoDefs = map (
      system: let
        denoDef = denoMap.${system};
      in
        nixpkgs.legacyPackages.aarch64-darwin.fetchzip {
          url = "https://github.com/denoland/deno/releases/download/v2.0.2/${denoDef.name}";
          sha256 = denoDef.hash;
        }
    ) (builtins.attrNames denoMap);
  in
    flake-utils.lib.eachSystem (builtins.attrNames denoMap) (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        denoDef = denoMap.${system};
        denoBin = pkgs.fetchzip {
          url = "https://github.com/denoland/deno/releases/download/v2.0.2/${denoDef.name}";
          sha256 = denoDef.hash;
        };
        deno = pkgs.stdenv.mkDerivation {
          name = "deno";
          src = denoBin;
          buildInputs = [denoDefs];
          buildPhase = "";
          installPhase = ''
            mkdir -p $out/bin
            cp ./deno $out/bin/
          '';
        };
      in {
        packages.default = deno;
      }
    );
}
