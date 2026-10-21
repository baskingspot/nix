_: {
  perSystem =
    { pkgs, ... }:
    let
      docgen = pkgs.callPackage ../pkgs/docgen { };

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
          coreutils
          findutils
          gawk
          gnugrep
          zola
        ];
        runtimeEnv.BASKINGSPOT_DOCS_THEME = "${../docs/theme}";
        text = builtins.readFile ./docs-cli.sh;
      };
    in
    {
      packages.docgen = docgen;

      # Zola, the theme, wrangler, and docgen for a repo's docs site. The repo
      # adds its own code toolchain; the API reference generator is here.
      devShells.docs = pkgs.mkShell {
        packages = [
          pkgs.zola
          wrangler
          baskingspotDocs
          docgen
        ];
      };
    };
}
