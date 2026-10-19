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

`[extra]` in `docs/config.toml` takes `repo = "baskingspot/NAME"` for the GitHub and license links, `api = true` for an "API reference" link to `api/`, `third_party = true` for a link to `THIRD_PARTY.md`, and `license = "Apache-2.0"` when the repo is not MIT. The footer defaults to MIT.

Add `docs/themes/` to `.gitignore`. It holds a link the command makes.

## The markdown copy

`baskingspot-docs build` writes a markdown copy of every page next to the HTML,
at the path of the page with `index.md` in place of `index.html`. Zola does not
copy its input, so the command copies `content/` itself, with three changes:

- the TOML frontmatter becomes an H1 from the `title`,
- `load_data` is replaced by the file it names, since a copy cannot render a
  shortcode and the code is most of what a reader came for,
- any other shortcode is left as it is, with a warning on stderr.

The router at baskingspot.dev serves the copy when a request asks for markdown.
See `baskingspot/site`'s README.

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
