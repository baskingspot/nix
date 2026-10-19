# baskingspot/nix: shared flake-parts modules. README.md says what is in it.
# AGENTS.md holds the working conventions.

[private]
default:
    @just --list

[doc("Check Nix, shell, the theme's CSS, Markdown, the justfile, and the workflows")]
[group("lint")]
lint:
    nix fmt -- --ci
    shfmt -d modules/docs-cli.sh
    shellcheck modules/docs-cli.sh
    oxfmt --check README.md AGENTS.md docs/README.md docs/theme/static/style.css .github
    actionlint
    zizmor .
    just --fmt --check

[doc("Format everything lint checks, and apply the statix and deadnix fixes")]
[group("lint")]
fmt:
    nix fmt
    shfmt -w modules/docs-cli.sh
    oxfmt README.md AGENTS.md docs/README.md docs/theme/static/style.css .github
    just --fmt

[doc("Evaluate every flake output, build every devshell, and run the Nix lint as a flake check")]
[group("test")]
check:
    nix flake check

[doc("Build the fixture site on the docs theme and check its output, the way a library's doc recipe does")]
[group("test")]
test-docs:
    #!/usr/bin/env bash
    set -euo pipefail
    out=$(mktemp -d)
    trap 'rm -rf "$out"' EXIT
    BASKINGSPOT_DOCS_ROOT=docs/fixture BASKINGSPOT_DOCS_OUT="$out" baskingspot-docs build fixture
    for f in index.html style.css badge.svg logo.svg social.png; do test -s "$out/fixture/$f"; done
    grep -q 'href="https://baskingspot.dev/fixture/style.css"' "$out/fixture/index.html"
    grep -q 'View on GitHub' "$out/fixture/index.html"
    grep -q 'class="layout has-toc"' "$out/fixture/index.html"
    # The markdown twin: an H1 from the title, no TOML frontmatter, and the
    # load_data example expanded, since a copy cannot render a shortcode.
    test -s "$out/fixture/index.md"
    head -1 "$out/fixture/index.md" | grep -qx '# fixture'
    ! grep -q '^+++$' "$out/fixture/index.md"
    grep -q 'pub const hello = "world";' "$out/fixture/index.md"
    ! grep -q 'load_data' "$out/fixture/index.md"

[doc("Everything CI runs")]
[group("ci")]
ci: lint check test-docs

[doc("Pin every Action to a commit SHA, leaving versions as they are. Needs GITHUB_TOKEN")]
[group("actions")]
pin:
    pinact run

# Three days of trailing age for other people's actions, so a hijacked tag has
# time to be caught. Our own org's actions skip the age rule, so a release in
# baskingspot/gh-actions reaches every repo at once.
[doc("Pin every Action to its newest release. Outside baskingspot, at least three days old. Needs GITHUB_TOKEN")]
[group("actions")]
update:
    pinact run --update --min-age 3 --exclude '^baskingspot/'
    pinact run --update --include '^baskingspot/'
