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
    let
      astGrepRules = pkgs.callPackage ../pkgs/ast-grep-rules { };
      baskingspotLint = pkgs.callPackage ../pkgs/baskingspot-lint {
        rules = astGrepRules;
      };
    in
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
      # oxfmt formats the Markdown and the workflow YAML in every repo's lint.
      # `baskingspot-lint` carries the shared ast-grep house rules; a repo runs
      # it on its sources and keeps only its own opinions in .ast-grep/rules.
      packages.ast-grep-rules = astGrepRules;
      packages.baskingspot-lint = baskingspotLint;
      devShells.base = pkgs.mkShell {
        packages = with pkgs; [
          actionlint
          ast-grep
          baskingspotLint
          fd
          gh
          just
          oxfmt
          pinact
          ripgrep
          zizmor
          config.treefmt.build.wrapper
        ];
      };
    };
}
