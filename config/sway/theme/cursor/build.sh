#!/usr/bin/env bash
#
# Neo Brutalism cursor theme : Simp1e recolored with the palette,
# with a hard offset black shadow instead of the soft 35% one.
#
#   theme/cursor/build.sh            build and install to ~/.local/share/icons/Neobrutal
#
# Needs : git, python-pillow, rsvg-convert, xcursorgen

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="Neobrutal"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/icons/$NAME"
SIMP1E_REPO="https://gitlab.com/cursors/simp1e.git"
SIMP1E_REF="f8f8f3c09dd0aa31cc9bc5499c683aad025984be"
# shadow offset, in template units (one cursor = 24 units)
OFFSET=1.5

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
git clone -q "$SIMP1E_REPO" "$tmp/simp1e"
git -C "$tmp/simp1e" -c advice.detachedHead=false checkout -q "$SIMP1E_REF"
git -C "$tmp/simp1e" submodule -q update --init

cp "$HERE/$NAME.txt" "$tmp/simp1e/src/color_schemes/"

# the "shadows" layer sits exactly under the "cursors" layer : push it down-right
svg="$tmp/simp1e/src/templates/cursors.svg"
line="$(grep -n 'inkscape:label="shadows"' "$svg" | cut -d: -f1)"
[[ -n "$line" ]] || { echo "shadows layer not found in $svg" >&2; exit 1; }
to="$(awk -v o="$OFFSET" 'BEGIN { printf "translate(%g,%g)", 4 + o, 32 + o }')"
sed -i "${line},$((line + 2))s/translate(4,32)/$to/" "$svg"
grep -A2 'inkscape:label="shadows"' "$svg" | grep -q "translate(4,32)" && { echo "shadow offset patch failed" >&2; exit 1; }

"$tmp/simp1e/build.sh" --include="cursors.svg,$NAME.txt" >/dev/null

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -a "$tmp/simp1e/built_themes/$NAME" "$DEST"
echo "$NAME cursor theme → $DEST"
