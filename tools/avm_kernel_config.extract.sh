#!/bin/bash

usage() {
cat << EOF
Usage: $SELF [-h|--help] [-s|--size] firmware.image

       -h|--help       print this help and exit
       -s|--size       AVM kernel config area size in KB, sizes known so far:
                       VR9  boxes: 64KB (default)
                       GRX5 boxes: 96KB
       -2|--2nd        process 2nd kernel on boxes with two kernels

       firmware.image  original firmware image

       The output is written to STDOUT
EOF
}

SELF="$(basename "$0")"
MOD_TOOLS="$(dirname $(readlink -f ${0}))"

# process command line parameters
ARGS=$(getopt -o s:2 --long size:,2nd -n "${SELF}" -- "$@")
[ $? -eq 0 ] || { usage >&2; exit 1; }
eval set -- "${ARGS}"
while true; do
	case "$1" in
		-h|--help)
			usage
			exit 0
			;;
		-s|--size)
			if ! echo "$2" | grep -qE "^[1-9][0-9]*$"; then
				echo >&2 "Error: invalid $1 parameter \"$2\", it's expected to be a positive number"
				usage >&2
				exit 1
			fi
			SIZE="$2"
			shift 2
			;;
		-2|--2nd)
			SECOND=1
			shift
			;;
		--)
			shift
			break
			;;
		*)
			echo >&2 "ERROR: internal error!"
			exit 1
			;;
	esac
done

[ $# -ne 1 ] && { usage >&2; exit 1; }

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

# unpack kernel, capture kernel load address(es)
declare -a load_addr
load_addr=($($MOD_TOOLS/unpack-kernel kernel.raw kernel.raw.unpacked 2>/dev/null | sed -nre 's,.*LoadAddress=(.+),\1,p'))
if [ $? -ne 0 -o ! -s "$tmp_dir/kernel.raw.unpacked" ]; then
	echo >&2 "ERROR: unpacking kernel failed"; exit 1;
fi

# and finally extract avm_kernel_config from the unpacked kernel
if [ "$SECOND" ]; then
	[ -s "$tmp_dir/kernel.raw.unpacked.2ND" ] || { echo >&2 "ERROR: 2nd kernel not found"; exit 1; }
	$MOD_TOOLS/avm_kernel_config.extract ${SIZE:+-s $SIZE} -l ${load_addr[1]} "$tmp_dir/kernel.raw.unpacked.2ND"
else
	$MOD_TOOLS/avm_kernel_config.extract ${SIZE:+-s $SIZE} -l ${load_addr[0]} "$tmp_dir/kernel.raw.unpacked"
fi

# pass exit code through
exit $?
