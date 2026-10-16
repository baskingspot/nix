# shellcheck shell=bash
# baskingspot-docs: build and serve a docs site on the baskingspot theme.
#
#   baskingspot-docs build SLUG   build docs/ into zig-out/site/SLUG/
#   baskingspot-docs serve SLUG   serve docs/ with live reload
#
# The site is served at https://baskingspot.dev/SLUG/, so it is built for that
# prefix. BASKINGSPOT_DOCS_THEME names the theme directory, and the devshell
# sets it. BASKINGSPOT_DOCS_ROOT (default docs) and BASKINGSPOT_DOCS_OUT
# (default zig-out/site) move the input and the output.

usage() {
	echo "usage: baskingspot-docs build|serve SLUG" >&2
	exit 2
}

[ "$#" -eq 2 ] || usage
command=$1
slug=$2
root=${BASKINGSPOT_DOCS_ROOT:-docs}
out=${BASKINGSPOT_DOCS_OUT:-zig-out/site}/$slug

# Zola finds a theme in <root>/themes/<name>. The link is a build product, so
# a repo ignores docs/themes/.
mkdir -p "$root/themes"
ln -sfn "$BASKINGSPOT_DOCS_THEME" "$root/themes/baskingspot"

case $command in
build)
	zola --root "$root" build --base-url "https://baskingspot.dev/$slug" --output-dir "$out" --force
	# A page that links to /style.css works at the domain root and breaks under
	# /SLUG/. Zola's own links honor base_url, so a hit here is a hand-written
	# root-absolute path.
	if hits=$(grep -rEo --include='*.html' '(href|src|srcset)="/[^/"][^"]*"' "$out"); then
		echo "root-absolute links break under /$slug/. Use relative links:" >&2
		echo "$hits" >&2
		exit 1
	fi
	;;
serve)
	zola --root "$root" serve
	;;
*)
	usage
	;;
esac
