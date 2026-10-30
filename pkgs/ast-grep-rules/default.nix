{ runCommand }:

# The shared ast-grep rules, one directory per language. `baskingspot-lint`
# runs every rule in order; a repo's own rules live in .ast-grep/rules.
runCommand "ast-grep-rules" { } ''
  mkdir -p $out
  cp -r ${./rules} $out/rules
''
