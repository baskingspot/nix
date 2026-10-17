# AGENTS.md

Working notes for AI coding agents in baskingspot/nix.

## What this is

Shared flake-parts modules for every baskingspot repo. A module here is copied into the flake of each library, so it has to be a pattern worth copying.

## Environment

The flake is the tool contract. `nix develop` provides every tool, and the `.envrc` loads it through direnv. The justfile is the command interface. Run `just fmt` before you commit, and `just ci` to run what CI runs.

## Layout

- `flake.nix` exports `flakeModules` and `templates`, and owns this repo's own devshell.
- `modules/<name>.nix` is one module. Each adds one `devShells.<name>`.
- `templates/zig-library/` is the flake a new Zig library starts from.

## Writing a module

- A module that needs this flake's own inputs, such as `mattware`, takes them as a first argument: `{ mattware }: { ... }: { ... }`. Export it with `importApply`. Without it, `inputs` inside the module means the consumer's inputs, and `mattware` is not there.
- A module that needs only nixpkgs is exported as a plain path.
- A toolchain is a version namespace: `zig."0.16"`. The module takes `version`, maps it to the nixpkgs attribute suffix, and sets `devShells.zig`. A consumer imports exactly one, and two versions conflict on that attribute. That conflict is the intended failure. Add a version by adding an entry to the namespace in `flake.nix`.
- A language gets its own module, named for the language: `zig`, `terraform`, `shell`, `docker`. It supplies that language's formatter and linter, from the table in the `.github` repo's `docs/TOOLING.md`. A repo imports the language modules it has, and composes their shells with `inputsFrom`. `base` stays small: only what every repo needs.
- `docs` is the one module that is not a language. It carries the docs theme in `docs/theme/`, and `just test-docs` builds a fixture site on it in CI. A change to the theme changes every library's site on its next lock update, so look at the fixture and at stdx before you push one.
- A module carries only the tools of its own language or concern. `oxfmt` is the exception: every repo's lint runs it, so `base` has it, and a repo does not list it in its own `packages`.
- A tool that lives in a language ecosystem runs through that ecosystem's own toolchain when the repo has its manifest: `uvx` with a `pyproject.toml`, `bunx` or `npx` with a `package.json`. The manifest pins the version. A module never ships `ruff`, `ty`, or JavaScript tooling for that case. The flake carries such a tool only when the repo has no manifest for it.
- `nix fmt` is for Nix files only. `base` imports the treefmt-nix module and enables `nixfmt`, `statix`, and `deadnix`, and nothing else. No module adds a treefmt program for another language. Every other language is formatted and linted by its own toolchain, from the repo's justfile, so a module only supplies the tools.
- Only `base` sets `systems`, with `lib.mkDefault`. A consumer can narrow it.
- Put options under `baskingspot.<name>.*`, and give every option that interpolates `${system}` a `defaultText`.
- `inputsFrom` does not carry `env` or `shellHook` into the consumer's shell. A tool that needs either gets its own shell, or an option the consumer applies.
- Consumers pin their own `nixpkgs`. Never make a consumer follow this flake's nixpkgs for them.

## Conventions

- Recipes carry a `[doc("...")]` directive and a `[group("...")]`. Format Nix with `nix fmt`, never `nixfmt` directly.
- Commit messages are one line, `area: summary`. Every commit is signed. Do not rewrite pushed history.
- Pin every `uses:` by SHA with a version comment. `just pin` pins a new one and `just update` moves them all. The runner label is pinned too, in any workflow that sets one.
- The maintenance job in `gh-actions` runs `nix flake update` here every week. Do not bump inputs by hand without a reason.
- Public text follows the voice guide in the `.github` repo, `docs/VOICE.md`.
