#!/usr/bin/env bash
#
# Neo Brutalism cursor themes : Simp1e recolored with the palette,
# with a hard offset black shadow instead of the soft 35% one.
# One theme per accent color (Neobrutal-Yellow, Neobrutal-Red, …), so that
# theme/neobrutal.sh can switch the accent without rebuilding anything.
#
#   theme/cursor/build.sh            build and install to ~/.local/share/icons/Neobrutal-*
#
# Needs : git, python-pillow, rsvg-convert, xcursorgen

set -euo pipefail
# mawk (Ubuntu) follows the locale : keep "." as the decimal separator in the SVG
export LC_ALL=C

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICONS="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
SIMP1E_REPO="https://gitlab.com/cursors/simp1e.git"
SIMP1E_REF="f8f8f3c09dd0aa31cc9bc5499c683aad025984be"
ACCENTS=(yellow red blue green purple orange cyan pink)
# rendered sizes : keep in sync with CURSOR_SIZES in theme/neobrutal.sh
SIZES=24,32,48,72
# shadow offset, in template units (one cursor = 24 units)
OFFSET=1.5

# accent hex values (identical in both palettes)
# shellcheck source=/dev/null
source "$HERE/../neobrutal/dark.bash"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
git clone -q "$SIMP1E_REPO" "$tmp/simp1e"
git -C "$tmp/simp1e" -c advice.detachedHead=false checkout -q "$SIMP1E_REF"
git -C "$tmp/simp1e" submodule -q update --init

schemes="$tmp/simp1e/src/color_schemes"
rm -f "$schemes"/*.txt
for a in "${ACCENTS[@]}"; do
	hex="${!a}"
	sed -e "s/@NAME@/${a^}/" -e "s/@ACCENT@/${hex#\#}/" "$HERE/scheme.txt" > "$schemes/Neobrutal-${a^}.txt"
done

# the "shadows" layer sits exactly under the "cursors" layer : push it down-right
svg="$tmp/simp1e/src/templates/cursors.svg"
line="$(grep -n 'inkscape:label="shadows"' "$svg" | cut -d: -f1)"
[[ -n "$line" ]] || { echo "shadows layer not found in $svg" >&2; exit 1; }
to="$(awk -v o="$OFFSET" 'BEGIN { printf "translate(%g,%g)", 4 + o, 32 + o }')"
sed -i "${line},$((line + 2))s/translate(4,32)/$to/" "$svg"
grep -A2 'inkscape:label="shadows"' "$svg" | grep -q "translate(4,32)" && { echo "shadow offset patch failed" >&2; exit 1; }

"$tmp/simp1e/build.sh" --include=cursors.svg --sizes="$SIZES" >/dev/null

mkdir -p "$ICONS"
for a in "${ACCENTS[@]}"; do
	name="Neobrutal-${a^}"
	[[ -d "$tmp/simp1e/built_themes/$name/cursors" ]] || { echo "$name was not built" >&2; exit 1; }
	rm -rf "${ICONS:?}/$name"
	cp -a "$tmp/simp1e/built_themes/$name" "$ICONS/$name"
done
# leftover of the single-theme build (now a pointer written by theme/neobrutal.sh)
[[ -d "$ICONS/Neobrutal/cursors" ]] && rm -rf "${ICONS:?}/Neobrutal"
echo "cursor themes → $ICONS/Neobrutal-{$(IFS=,; echo "${ACCENTS[*]^}")}"
