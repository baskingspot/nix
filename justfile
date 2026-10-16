# baskingspot/nix: shared flake-parts modules. README.md says what is in it.
# AGENTS.md holds the working conventions.

[private]
default:
    @just --list

[doc("Check Nix, Markdown, the justfile, and the workflows")]
[group("lint")]
lint:
    nix fmt -- --ci
    oxfmt --check README.md AGENTS.md
    actionlint
    zizmor .
    just --fmt --check

[doc("Format everything lint checks, and apply the statix and deadnix fixes")]
[group("lint")]
fmt:
    nix fmt
    oxfmt README.md AGENTS.md
    just --fmt

[doc("Evaluate every flake output, build every devshell, and run the Nix lint as a flake check")]
[group("test")]
check:
    nix flake check

[doc("Everything CI runs")]
[group("ci")]
ci: lint check

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
