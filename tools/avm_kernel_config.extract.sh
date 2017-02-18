#!/bin/bash

usage() {
cat << EOF
Usage: $SELF firmware.image
       The output is written to STDOUT
EOF
}

SELF="$(basename "$0")"
MOD_TOOLS="$(dirname $(readlink -f ${0}))"

[ $# -ne 1 ] && { usage; exit 1; }

fw_image="$1"
[ -f "$fw_image" ] || { echo >&2 "ERROR: \"$fw_image\" not found"; exit 1; }

tmp_dir=$(mktemp -d)
[ $? -eq 127 ] && tmp_dir="/tmp/tmp.$(date +%s).$$" && mkdir -p "$tmp_dir"

trap "rm -r \"$tmp_dir\"" EXIT HUP

d="var/tmp"
tar -C "$tmp_dir" -xif "$fw_image" --wildcards "./${d}/*.image" >/dev/null 2>&1

cd "$tmp_dir"

# remove TI checksum and concatenate kernel & filesystem images
for f in "${d}/kernel.image" "${d}/filesystem.image"; do
	if [ -s "$f" ]; then
		$MOD_TOOLS/tichksum -r "$f" >/dev/null 2>&1
		cat "$f" | dd bs=256 conv=sync 2>/dev/null;
	fi
done > kf.image

# strip NMI vector if any
{ $MOD_TOOLS/remove-nmi-vector kf.image kf.image.no-nmi && mv kf.image.no-nmi kf.image; } >/dev/null 2>&1

# and split them again... now at the right bounds
$MOD_TOOLS/find-squashfs kf.image >/dev/null 2>&1 || { echo >&2 "ERROR: splitting kernel & filesystem images failed"; exit 1; }

# unpack kernel
$MOD_TOOLS/unpack-kernel kernel.raw kernel.raw.unpacked >/dev/null 2>&1 || { echo >&2 "ERROR: unpacking kernel failed"; exit 1; }

# and finally extract avm_kernel_config from the unpacked kernel
$MOD_TOOLS/avm_kernel_config.extract "$tmp_dir/kernel.raw.unpacked"

# pass exit code through
exit $?
