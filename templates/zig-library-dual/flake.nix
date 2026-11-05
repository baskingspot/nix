{
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
      # imports and inputsFrom below mirror each other, including the
      # toolchain versions. Both build: the default is the current stable,
      # and `zig-old` is the previous one for the CI compatibility lane and
      # for local checks.
      imports = with inputs.baskingspot.flakeModules; [
        base
        zig."0.16"
        zig."0.17"
      ];

      perSystem =
        { pkgs, config, ... }:
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.devShells.base
              config.devShells."zig-0-17"
            ];

            # ziglint reads the 0.16 standard library, so a deprecation that
            # only 0.17 made does not fire while 0.16 is supported.
            packages = [ config.packages."ziglint-0-16" ];
          };

          devShells.zig-old = pkgs.mkShell {
            inputsFrom = [
              config.devShells.base
              config.devShells."zig-0-16"
            ];

            # The same wrapper, so one `just lint` works in either shell.
            packages = [ config.packages."ziglint-0-16" ];
          };
        };
    };
}
