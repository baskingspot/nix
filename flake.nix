{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mattware = {
      url = "github:mattrobenolt/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      inherit (flake-parts.lib) importApply;
      withMattware = { inherit (inputs) mattware; };
      # Not named `base`: the `with config.devShells` below would not see through it.
      baseModule = importApply ./modules/base.nix { inherit (inputs) treefmt-nix; };
      zig = version: importApply ./modules/zig.nix (withMattware // { inherit version; });
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.templates.zig-library = {
        path = ./templates/zig-library;
        description = "A Zig library with the baskingspot devshell";
      };

      flake.flakeModules = {
        base = baseModule;
        docker = ./modules/docker.nix;
        docs = ./modules/docs.nix;
        shell = ./modules/shell.nix;
        terraform = ./modules/terraform.nix;
        # A version namespace: consumers import zig."0.16" (exactly one).
        zig = {
          "0.16" = zig "0.16";
          "0.17" = zig "0.17";
        };
      };

      imports = [
        baseModule
        ./modules/docker.nix
        ./modules/docs.nix
        ./modules/shell.nix
        ./modules/terraform.nix
      ];

      perSystem =
        { pkgs, config, ... }:
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = with config.devShells; [
              base
              docs
              shell
            ];

            # Markdown is this repo's own concern. Modules do not carry oxfmt.
            packages = [ pkgs.oxfmt ];
          };
        };
    };
}
