{ treefmt-nix }:
{ lib, ... }:
{
  imports = [ treefmt-nix.flakeModule ];

  systems = lib.mkDefault [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  perSystem =
    { pkgs, config, ... }:
    {
      # `nix fmt` handles Nix files and nothing else. Every other language is
      # formatted and linted by its own toolchain, through the repo's justfile.
      # `nix fmt -- --ci` fails when a Nix file would change, and
      # `nix flake check` runs the same check.
      treefmt = {
        projectRootFile = lib.mkDefault "flake.nix";
        programs = {
          nixfmt.enable = true;
          # statix and deadnix fix what they find, so a check run fails on
          # the diff.
          statix.enable = true;
          deadnix.enable = true;
        };
      };

      # Every repo is a GitHub repo, so the workflow tools are here too. The
      # repo's justfile runs actionlint and zizmor, and pins with pinact.
      devShells.base = pkgs.mkShell {
        packages = with pkgs; [
          actionlint
          fd
          gh
          just
          pinact
          ripgrep
          zizmor
          config.treefmt.build.wrapper
        ];
      };
    };
}
