{
  ast-grep,
  rules,
  writeShellApplication,
}:

writeShellApplication {
  name = "baskingspot-lint";
  runtimeInputs = [ ast-grep ];
  runtimeEnv.BASKINGSPOT_RULES = "${rules}/rules";
  text = builtins.readFile ./baskingspot-lint.sh;
}
