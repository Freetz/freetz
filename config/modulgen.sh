#!/bin/bash
#by cuma

SCRIPT="$(readlink -f $0)"
PARENT="$(dirname ${SCRIPT%/*})"
PDIR="config/.kos"
PROP="$PARENT/$PDIR"
CINTMP="$PROP/Config.in"
SYMS="AUTOFS4_FS EXT2_FS EXT3_FS EXT4_FS FUSE_FS JFFS2_FS  NLS_CODEPAGE_437 NLS_ISO8859_1 NLS_ISO8859_15 NLS_UTF8  TUN
CRYPTO_ALGAPI CRYPTO_AEAD CRYPTO_AES CRYPTO_ARC4 CRYPTO_BLKCIPHER CRYPTO_CBC CRYPTO_HASH CRYPTO_MANAGER CRYPTO_MD4 CRYPTO_PCOMP CRYPTO_RNG CRYPTO_SHA1 CRYPTO_SHA256 CRYPTO_WORKQUEUE"

rm -rf "$PROP"
mkdir -p "$PROP"
touch "$CINTMP"

for src in $PARENT/make/linux/configs/avm/*; do
	src="${src%--not-available}"
	[ ! -e "$src" ] && src="${src/avm/freetz}"

	case ${src##*/} in
		config-ar7-04.33)        sym="04_33 && !FREETZ_TYPE_7140 && FREETZ_SYSTEM_TYPE_AR7_SANGAM"  ;;
		config-ohio-04.33)       sym="04_33 && !FREETZ_TYPE_7140 && FREETZ_SYSTEM_TYPE_AR7_OHIO"    ;;
		config-ohio-7140_04.33)  sym="04_33 && FREETZ_TYPE_7140"                                    ;;
		config-ohio-5140_04.67)  sym="04_67 && FREETZ_TYPE_5140"                                    ;;
		config-ohio-04.67)       sym="04_67 && !FREETZ_TYPE_5140"                                   ;;
		config-ohio-r7203)       sym="r7203"                                                        ;;
		*)                       sym="$(echo $src | sed 's/.*-//;s/\./_/')"                         ;;
	esac
	echo "source \"$PDIR/${src##*/}.in\"" >> "$CINTMP"

	out="$PROP/${src##*/}.in"
	echo -e "if FREETZ_AVM_SOURCE_$sym\n" > "$out"
	for sym in $SYMS; do
		grep -q "^CONFIG_$sym=y$" "$src" && echo -e "config FREETZ_AVM_HAS_${sym}_BUILTIN\n\tdef_bool y\n" >> "$out"
	done
	echo "endif" >> "$out"

done

