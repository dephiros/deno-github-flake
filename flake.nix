{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    version = "v2.0.4";
    urlMap = {
      x86_64-linux = {
        url = "https://github.com/denoland/deno/releases/download/v2.0.4/deno-x86_64-unknown-linux-gnu.zip";
        hash = "sha256-tkuOgKZ6XoFJwSo/75yDnc771M01vXxaXzYaO+cnZbA=";
      };
      aarch64-linux = {
        url = "https://github.com/denoland/deno/releases/download/v2.0.4/deno-aarch64-unknown-linux-gnu.zip";
        hash = "sha256-CY0A8HABkXkjbb8ZbSL5sZT1NZjQJq4m+RjbSPBl0eI=";
      };
      x86_64-darwin = {
        url = "https://github.com/denoland/deno/releases/download/v2.0.4/deno-x86_64-apple-darwin.zip";
        hash = "sha256-nCz4y8nt09+OBjXylHBT8KnGa2+/zKcQUmaF8gQd2IE=";
      };
      aarch64-darwin = {
        url = "https://github.com/denoland/deno/releases/download/v2.0.4/deno-aarch64-apple-darwin.zip";
        hash = "sha256-gZ0nPtMMd9GJQXH2BZ3r/s1FvhI9Aw6I2ec8lKpE/U0=";
      };
    };
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        getDeno = {
          pkgs,
          targetSystem ? system,
        }: let
          denoPrebuilt = pkgs.fetchzip {
            url = urlMap.${targetSystem}.url;
            hash = urlMap.${targetSystem}.hash;
          };
        in
          pkgs.stdenv.mkDerivation {
            name = "deno";
            src = denoPrebuilt;
            buildInputs = [];
            buildPhase = "";
            installPhase = ''
              mkdir -p $out/bin
              cp ./deno $out/bin/
            '';
          };
      in {
        formatter = pkgs.alejandra;
        packages.default = getDeno {inherit pkgs;};
        # nix shell .\#x86_64-linux .\#aarch64-linux .\#aarch64-linux .\#aarch64-darwin 
        packages.x86_64-linux = getDeno {
          inherit pkgs;
          targetSystem = "x86_64-linux";
        };

        packages.aarch64-linux = getDeno {
          inherit pkgs;
          targetSystem = "aarch64-linux";
        };
        packages.x86_64-darwin = getDeno {
          inherit pkgs;
          targetSystem = "x86_64-darwin";
        };
        packages.aarch64-darwin = getDeno {
          inherit pkgs;
          targetSystem = "aarch64-darwin";
        };
      }
    );
}
