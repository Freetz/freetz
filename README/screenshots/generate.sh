#!/bin/bash
# generates thumbnails of docs/screenshots/000-* to docs/screenshots/999-*
MYPWD="$(dirname $(realpath $0))"

for file in $MYPWD/*.???; do
src="${file##*/}"
dst="${src%.*}_md.${src##*.}"
[ "${dst/_md_md./}" != "$dst" ] && continue
[ -e "$MYPWD/$dst" ] && continue
echo "$src -> $dst"
convert "$MYPWD/$src" -resize x333 "$MYPWD/$dst"
done

