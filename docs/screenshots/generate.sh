#!/bin/bash
# generates thumbnails of docs/screenshots/000-* to docs/screenshots/999-*
MYPWD="$(dirname $(realpath $0))"

for file in $MYPWD/000-*; do
src="${file##*/}"
dst="999-${src##000-}"
[ -e "$MYPWD/$dst" ] && continue
echo "$src -> $dst"
convert "$MYPWD/$src" -resize x333 "$MYPWD/$dst"
done
echo "done."

