{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    # let flake handle hash. The tradeoff is we would need to download for all systems
    deno-x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v2.0.2/deno-x86_64-unknown-linux-gnu.zip";
      flake = false;
    };
    deno-aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v2.0.2/deno-aarch64-unknown-linux-gnu.zip";
      flake = false;
    };
    deno-x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v2.0.2/deno-x86_64-apple-darwin.zip";
      flake = false;
    };
    deno-aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v2.0.2/deno-aarch64-apple-darwin.zip";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        denoInput = "deno-${system}";
        pkgs = nixpkgs.legacyPackages.${system};
        deno = pkgs.stdenv.mkDerivation {
          name = "deno";
          src = inputs.${denoInput};
          buildInputs = [];
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
