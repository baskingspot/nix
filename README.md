<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/static/logo-dark.svg">
    <img src="docs/static/logo.svg" alt="nix" height="48">
  </picture>
</h1>

Shared flake-parts modules for baskingspot development environments.

Every baskingspot repo needs the same flake skeleton and the same tools. This repo exports them as flake-parts modules. Each module adds one `devShells.<name>`, and a repo composes the ones it wants with `inputsFrom`.

## Modules

- `base`: the three supported systems, and `nix fmt` through treefmt, for Nix files only. It formats with `nixfmt` and fixes with `statix` and `deadnix`. The devshell has `treefmt`, `just`, `fd`, `gh`, `oxfmt` (it formats the Markdown and the workflows in every repo's lint), and the workflow tools `actionlint`, `zizmor`, and `pinact`, because every repo is a GitHub repo. It also has `ast-grep` and `baskingspot-lint`, which runs the house rules.
- `terraform`: OpenTofu and `tflint`. `tofu fmt` formats, and `tflint` and `tofu validate` check.
- `shell`: `shellcheck` and `shfmt`. Shell scripts are always checked.
- `docker`: the Docker CLI with buildx, and `hadolint`. Dockerfiles are always checked. The daemon is not in the shell.
- `docs`: a docs site on the baskingspot theme: Zola, a pinned `wrangler`, and the command `baskingspot-docs`. It is not a language. See `docs/README.md`.
- `zig`: Zig, the matching `zls`, `ziglint`, and `zigdoc`. It is a version namespace with `0.16` and `0.17`. A version's shell is `devShells."zig-0-16"` or `devShells."zig-0-17"`, and a repo imports the versions it supports. The dot becomes a hyphen because `nix develop .#zig-0.16` reads the dot as an attrpath separator. Each version also exposes `ziglint-0-16` or `ziglint-0-17`, which runs ziglint against that version's standard library; a repo that supports two versions lints with the oldest, so the newer version's deprecations do not fire.

## Lint

Nix has no `nix lint`. The closest standard is `nix fmt`, so `base` puts the Nix linters behind it with [treefmt-nix](https://github.com/numtide/treefmt-nix).

- `nix fmt` formats Nix files and applies the `statix` and `deadnix` fixes.
- `nix fmt -- --ci` changes nothing and fails if a Nix file would change.
- `nix flake check` runs the same check.

`nix fmt` touches `*.nix` and nothing else. Every other language stays with its own toolchain, run from the repo's justfile: `zig fmt` and `ziglint`, `oxfmt` for Markdown, `actionlint` and `zizmor` for workflows, and `just --fmt`.

The house rules are ast-grep rules under `pkgs/ast-grep-rules/rules/`, one directory per language. `baskingspot-lint src` runs all of them, then any in the repo's own `.ast-grep/rules/`. A rule that applies to every repo is added here once; a repo runs the same command with no other change. Each rule carries valid and invalid Zig cases in `pkgs/ast-grep-rules/tests/`; `just test-rules` runs them, and `nix flake check` runs the same test in CI.

## Use

Start a new library from the template:

```sh
nix flake init -t github:baskingspot/nix#zig-library
```

A library that has to build on the current Zig and on the previous release starts from `zig-library-dual`. It imports both versions, adds a `zig-old` shell, and the `check` recipe the compatibility lane runs:

```sh
nix flake init -t github:baskingspot/nix#zig-library-dual
```

Or add the modules to an existing flake:

```nix
imports = with inputs.baskingspot.flakeModules; [
  base
  zig."0.16"
];

perSystem = { pkgs, config, ... }: {
  devShells.default = pkgs.mkShell {
    inputsFrom = with config.devShells; [ base zig ];
    packages = with pkgs; [ ];
  };
};
```

The `imports` list and the `inputsFrom` list mirror each other. Pick the Zig version once, in the import.

The flake sets no `nixConfig`, so a repo does not ask you to trust a cache when you enter it. To use the org's caches, add them to your own Nix configuration:

```
extra-substituters = https://baskingspot.cachix.org https://mattrobenolt.cachix.org
extra-trusted-public-keys = baskingspot.cachix.org-1:4KDZc1xfJdL8VGAOZo1SkOgZlqMNH+thBzux9J66EjU= mattrobenolt.cachix.org-1:sn1IDSC4OxQvWaOVD4RRcqyKlket5wgb11nd1QII6i8=
```

`ziglint` and `zigdoc` come from [mattware](https://github.com/mattrobenolt/nixpkgs), which this flake pins. Your `nixpkgs` stays your own pin.

## Work on it

`nix develop` provides the tools, and `direnv allow` loads them. `just` lists the recipes, and `just ci` runs what CI runs.

## License

MIT. See `LICENSE`. The logo files in `docs/static/` are baskingspot marks and are not covered by it. See `docs/static/LICENSE`.

## How it's made

Built with LLM assistance. [How, in detail](https://github.com/baskingspot/.github/blob/main/docs/AI.md).

<a href="https://github.com/baskingspot"><img src="https://raw.githubusercontent.com/baskingspot/.github/main/brand/assets/badge.svg" alt="baskingspot" height="24"></a>
