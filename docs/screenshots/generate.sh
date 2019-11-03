#!/bin/bash
# generates thumbnails of README/screenshots/* to docs/README/*_md.*
MYPWD="$(dirname $(realpath $0))"

for file in $MYPWD/*.???; do
src="${file##*/}"
dst="${src%.*}_md.${src##*.}"
[ "${dst/_md_md./}" != "$dst" ] && continue
[ -e "$MYPWD/$dst" ] && continue
echo "$src -> $dst"
convert "$MYPWD/$src" -resize x333 "$MYPWD/$dst"
chmod -x "$MYPWD/$src" "$MYPWD/$dst"
done

