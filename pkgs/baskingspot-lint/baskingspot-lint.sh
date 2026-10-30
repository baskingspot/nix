# shellcheck shell=bash
# baskingspot-lint: run the house ast-grep rules over a checkout.
#
#   baskingspot-lint [PATH...]   default: the current directory
#
# ast-grep takes one --rule per invocation, so the rules run in a loop: the
# shared ones from the flake, then any in the repo's own .ast-grep/rules.

status=0
paths=("$@")
if [ "${#paths[@]}" -eq 0 ]; then
	paths=(.)
fi

shopt -s nullglob

for rule in "$BASKINGSPOT_RULES"/*/*.yml; do
	ast-grep scan --rule "$rule" "${paths[@]}" || status=$?
done

for rule in .ast-grep/rules/*.yml; do
	ast-grep scan --rule "$rule" "${paths[@]}" || status=$?
done

exit "$status"
