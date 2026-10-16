# The docs module

`flakeModules.docs` gives a library's repo a docs site on the baskingspot theme, served at `baskingspot.dev/NAME/`. The module adds a `docs` devshell with Zola, wrangler, and the command `baskingspot-docs`. The theme is in `theme/`.

## Use it

Import the module, and compose its shell into the default shell:

```nix
imports = with inputs.baskingspot.flakeModules; [ base docs ];

devShells.default = pkgs.mkShell {
  inputsFrom = with config.devShells; [ base docs ];
};
```

The repo owns its content and its marks:

| Path                     | Content                                                                                |
| ------------------------ | -------------------------------------------------------------------------------------- |
| `docs/config.toml`       | `theme = "baskingspot"`, the title and description, and `[extra]` (below)              |
| `docs/content/_index.md` | The guide. Its headings become the contents sidebar                                    |
| `docs/static/`           | `logo.svg`, `logo-dark.svg`, `favicon.svg`, `social.png`, and anything the guide links |
| `wrangler.jsonc`         | The Worker `baskingspot-dev-NAME`, assets `./zig-out/site`, no routes                  |

The theme owns `style.css`, `badge.svg`, and the templates. A file of the same name in the repo wins, so a repo can override a template. Don't copy the theme's CSS.

`[extra]` in `docs/config.toml` takes `repo = "baskingspot/NAME"` for the GitHub and license links, `api = true` for an "API reference" link to `api/`, and `third_party = true` for a link to `THIRD_PARTY.md`.

Add `docs/themes/` to `.gitignore`. It holds a link the command makes.

## Recipes

```just
doc:
    baskingspot-docs build NAME

guide:
    baskingspot-docs serve NAME

doc-deploy: doc
    wrangler deploy
```

`build` writes `zig-out/site/NAME/` and fails if the HTML has a root-absolute `href` or `src`. Under `/NAME/`, a link to `/style.css` is a 404. Write relative links, such as `api/#symbol`. A library with an API reference runs `zig build docs` first, and its `build.zig` installs the viewer under `docs/static/api`.

Then register the site in `baskingspot/site`. See its README.
