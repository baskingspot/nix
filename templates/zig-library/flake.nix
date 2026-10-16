{
  # Pull from the org's caches. mattrobenolt holds ziglint and zigdoc until they
  # move under baskingspot. Nix asks once before it trusts these.
  nixConfig = {
    extra-substituters = [
      "https://baskingspot.cachix.org"
      "https://mattrobenolt.cachix.org"
    ];
    extra-trusted-public-keys = [
      "baskingspot.cachix.org-1:4KDZc1xfJdL8VGAOZo1SkOgZlqMNH+thBzux9J66EjU="
      "mattrobenolt.cachix.org-1:sn1IDSC4OxQvWaOVD4RRcqyKlket5wgb11nd1QII6i8="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.follows = "baskingspot/flake-parts";
    baskingspot = {
      url = "github:baskingspot/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # imports and inputsFrom below mirror each other, except the toolchain
      # version: pick that once, in the import.
      imports = with inputs.baskingspot.flakeModules; [
        base
        zig."0.16"
      ];

      perSystem =
        { pkgs, config, ... }:
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = with config.devShells; [
              base
              zig
            ];

            # Project-specific tools.
            packages = with pkgs; [ ];
          };
        };
    };
}
