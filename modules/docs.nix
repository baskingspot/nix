_: {
  perSystem =
    { pkgs, ... }:
    let
      # Wrangler as a thin wrapper: the flake pins the version and npm owns the
      # bits. The release-age guard is lifted for this one tool so a day-zero
      # release stays installable. `cf` was tried and dropped: `cf deploy`
      # needs a package.json, and these repos have none.
      wrangler = pkgs.writeShellApplication {
        name = "wrangler";
        runtimeEnv.NPM_CONFIG_MIN_RELEASE_AGE = "0";
        text = ''exec ${pkgs.nodejs_24}/bin/npx --yes "wrangler@4.150.0" "$@"'';
      };

      baskingspotDocs = pkgs.writeShellApplication {
        name = "baskingspot-docs";
        runtimeInputs = with pkgs; [
          zola
          gnugrep
        ];
        runtimeEnv.BASKINGSPOT_DOCS_THEME = "${../docs/theme}";
        text = builtins.readFile ./docs-cli.sh;
      };
    in
    {
      # Zola, the theme, and wrangler for a repo's docs site. The repo adds its
      # own toolchain, such as zig for an API reference.
      devShells.docs = pkgs.mkShell {
        packages = [
          pkgs.zola
          wrangler
          baskingspotDocs
        ];
      };
    };
}
