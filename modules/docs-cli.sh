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

# The markdown twin of a page: Zola's TOML frontmatter becomes an H1, and the
# body follows. Pages are written as markdown and built into HTML, so the twin
# is the source, not a conversion of the page. `load_data` is expanded, because
# the code it pulls in is most of what an example reader is after.
twin() {
	awk -v root="$root" '
		FNR == 1 && $0 == "+++" { front = 1; next }
		front && $0 == "+++" { front = 0; next }
		front {
			if ($0 ~ /^[ \t]*title[ \t]*=/) {
				title = $0
				sub(/^[ \t]*title[ \t]*=[ \t]*/, "", title)
				sub(/[ \t]+#.*$/, "", title)
				gsub(/^"|"$/, "", title)
			}
			next
		}
		{
			if (!started) {
				if ($0 == "") next
				started = 1
				if (title != "" && $0 !~ /^# /) printf "# %s\n\n", title
			}
			if ($0 ~ /^[ \t]*\{\{[ \t]*load_data\(path="/) {
				file = $0
				sub(/^[ \t]*\{\{[ \t]*load_data\(path="/, "", file)
				sub(/".*$/, "", file)
				found = 0
				while ((getline line < (root "/" file)) > 0) {
					print line
					found = 1
				}
				close(root "/" file)
				if (!found) {
					printf "warning: %s cannot be read\n", root "/" file > "/dev/stderr"
					print
				}
				next
			}
			print
		}
		END {
			if (!started && title != "") printf "# %s\n", title
		}
	' "$1"
}

# Zola builds HTML only, so every page is copied to the path of its URL with
# index.md in place of index.html. The router serves that file when a request
# asks for markdown. A shortcode is not expanded in a copy, so it is a warning
# rather than a silent lie in the twin.
twins() {
	src_root=$root/content
	[ -d "$src_root" ] || return 0
	find "$src_root" -type f -name '*.md' | sort | while IFS= read -r src; do
		rel=${src#"$src_root"/}
		case $rel in
		*_index.md) rel_out=${rel%_index.md}index.md ;;
		*) rel_out=${rel%.md}/index.md ;;
		esac
		dst=$out/$rel_out
		mkdir -p "$(dirname "$dst")"
		twin "$src" >"$dst"
		if grep -v 'load_data' "$src" | grep -q '{{'; then
			echo "warning: $src uses a shortcode, which the markdown twin cannot render" >&2
		fi
	done
}

# Zola finds a theme in <root>/themes/<name>. The link is a build product, so
# a repo ignores docs/themes/.
mkdir -p "$root/themes"
ln -sfn "$BASKINGSPOT_DOCS_THEME" "$root/themes/baskingspot"

case $command in
build)
	zola --root "$root" build --base-url "https://baskingspot.dev/$slug" --output-dir "$out" --force
	twins
	# A twin is a second copy of a page, so it stays out of search indexes. The
	# router sets this too when it negotiates; this covers a direct fetch of the
	# `.md` path, which the asset layer answers without the Worker.
	cat >"$out/_headers" <<'HEADERS'
# The markdown twins are a second copy of a page. Keep them out of search
# indexes; the HTML page is the one to find.
/*.md
  X-Robots-Tag: noindex, nofollow
HEADERS
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
