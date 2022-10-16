#!/bin/bash
[ "$(echo $USER | sha256sum)" != "804d5ac72a104f79eb8b3d4f537ed05207b711f717f4378008486749473ba70f  -" ] && echo "You dont want this" && exit 1
GITDIR="$HOME/freetz-ng"
DL_DIR="$HOME/.freetz-dl"
TEMPDIR="/tmp/avmpack"
WORKDIR="$HOME/vanilla"
AVM_DIR="$WORKDIR/avm"
ORG_DIR="$WORKDIR/org"
PXT_DIR="$WORKDIR/pxz"
VERSION='rLOCAL'
VERSION='ADv1'
OLD_VER='avm'


# patches vanilla 2 avm
# $1: avmdiff
vanilla2avm() {
	local avmdiff="$1"
	[ ! -e "$avmdiff" ] && echo "Usage: $0 vanilla2avm ~/.freetz-dl/kernel_*.patch.xz" && exit 1
	[ ! -e MAINTAINERS ] && echo "This direcory does not look like an unpacked kernel" && exit 1
	local TOOLS_DIR="$GITDIR/tools"
	local KERNEL_SOURCE_DIR='.'
	"$TOOLS_DIR/freetz_patch" "$KERNEL_SOURCE_DIR" $avmdiff
	find "$KERNEL_SOURCE_DIR" -type l -exec rm -f {} ';'
	xz -d $avmdiff -c | grep -E '^    #FREETZ# (mkdir|chmod|slink|touch) .*' | while read x a b c; do
		[ "$a" == "mkdir" ] && echo "$a: $b $c" && mkdir -p   "$KERNEL_SOURCE_DIR/${b}"
		[ "$a" == "chmod" ] && echo "$a: $b $c" && chmod +x   "$KERNEL_SOURCE_DIR/${b}"
		[ "$a" == "slink" ] && echo "$a: $b $c" && mkdir -p   "$KERNEL_SOURCE_DIR/${b%/*}"
		[ "$a" == "slink" ] && echo "$a: $b $c" && ln -s "$c" "$KERNEL_SOURCE_DIR/${b}"
		[ "$a" == "touch" ] && echo "$a: $b $c" && mkdir -p   "$KERNEL_SOURCE_DIR/${b%/*}"
		[ "$a" == "touch" ] && echo "$a: $b $c" && touch      "$KERNEL_SOURCE_DIR/${b}"
	done
}


# gets kerner version
# $1: directory
get_kernel_version() {
	local DIR="${1:-.}"
	local CFG="$(sed -n 's/.*KCONFIG_CONFIG = //p' $DIR/linux*/.kernelvariables 2>/dev/null)"
	[ -n "$CFG" ] && CFG="$DIR/linux*/$CFG" || CFG="$DIR/linux*/.config"
	grep -E 'Kernel Configuration|Linux kernel version' $CFG 2>/dev/null | grep -v '^$' | head -n1 | sed 's/x86//' | sed 's/[^0-9\.]//g' | sed 's/^$/UNKNOWN/g'
}

# creates vanilla patch 4 avm
# $1: (optional) avm (tiny) kernel pack
# $2: (optional) vanilla kernel version
# $3: (optional) SOURCE_ID = XXXX_XX.XX
vanilla4avm() {
	mkdir -p "$WORKDIR"
	local xz="$1" avm="$2" org hwr="$3"
	[ -z "$hwr" ] && hwr="${xz##*/}" && hwr="${hwr%%-*}"

	# check/unpack avmpack
	if [ -n "$xz" ]; then
		[ ! -e "$xz" ] && echo "Missinga: $xz" && exit 1
		echo "Unpack ${xz##*/}"
		rm -rf "$TEMPDIR"
		mkdir -p "$TEMPDIR"
		ln -sf "$TEMPDIR" "$AVM_DIR"
		tar xf $xz -C "$AVM_DIR"
	fi
	[ ! -e $AVM_DIR ] && echo "echo Put AVM's kernel sources unpacked into $AVM_DIR" && exit 1

	# avms crippled version
	avm="${avm:-$(get_kernel_version "$AVM_DIR")}"
	[ -z "$avm" ] && avm='2.6.13.1'
	[ "$avm" == '2.6.28.8' ] && avm='2.6.28.10'
	echo "avm=$avm"

	# used vanilla version
	org="$avm"
	[ "$avm" == '2.6.19.2' ] && org='2.6.19'
	[ "${avm%.*}" == '2.6.32' ] && org='2.6.32.27'
	echo "org=$org"

	# check/unpack vanilla
	if [ ! -e "$ORG_DIR/linux-$avm" ]; then
		[ ! -e "$DL_DIR/linux-$org.tar.xz" ] && echo "Missing: $DL_DIR/linux-$org.tar.xz" && exit 1
		echo "Kernel linux-$avm.tar.xz"
		mkdir -p "$ORG_DIR"
		tar xf "$DL_DIR/linux-$org.tar.xz" -C "$ORG_DIR"
	fi

	# create avmdiff
	mkdir -p "$PXT_DIR"
	local output="$PXT_DIR/kernel_$avm-${hwr:-XXXX_XX.XX}-$VERSION.patch"
	cd "$WORKDIR"
cat > "$output" <<EOX

This patch has been created from AVM's opensrc packages: https://osp.avm.de/
    diff -Naur --no-dereference org/linux-$org avm/linux* > this.patch

$(for x in $(find avm/linux* -type d -empty        ); do echo "    #FREETZ# mkdir ${x#avm/linux*/}"               ; done)
$(for x in $(find avm/linux* -type f -a -executable); do echo "    #FREETZ# chmod ${x#avm/linux*/}"               ; done)
$(for x in $(find avm/linux* -type l               ); do echo "    #FREETZ# slink ${x#avm/linux*/} $(readlink $x)"; done)
$(for x in $(find avm/linux* -type f -empty        ); do echo "    #FREETZ# touch ${x#avm/linux*/}"               ; done)

EOX
	diff -Naur --no-dereference org/linux-$org avm/linux* >> "$output" 2>/dev/null
#	return
	touch -d "2022-05-26 17:15:00.000000000 +0200" "$output"
	local packed="$output.xz"
	du -sh "$output"
	echo "Packing $packed"
	rm -f "$packed" 2>/dev/null
	xz "$output"
	du -sh "$packed"
	sha256sum "$packed"
}


generate_vanilla() {
	for x in $DL_DIR/kernel_*-$OLD_VER.patch.xz; do
		m="$(echo $x| sed "s/-$OLD_VER.patch.xz$//;s/.*-//")"
		$0 vanilla4avm $DL_DIR/fw/$m-release_kernel.tar.xz
	done

	# 6660_07.39
	rm -f kernel_4.9.250-6660_07.39.x86-*.patch
	$0 vanilla4avm "$DL_DIR/fw/6660_07.39.x86-release_kernel.tar.xz" "4.9.279"

	# 7582_07.15
	rm -f kernel_2.6.13.1-7582_07.15-*.patch
	rm -f "$AVM_DIR"
	ln -sf "$TEMPDIR/kernel" "$AVM_DIR"
	rm -rf "$TEMPDIR"
	mkdir -p "$TEMPDIR"
	tar xf "$DL_DIR/fw/7582_07.15-release_kernel.tar.xz" -C "$TEMPDIR"
	$0 vanilla4avm "" "4.1.38" "7582_07.15"

	# update hash
	for x in $PXT_DIR/*.patch.xz; do
		local file=${x##*/}
		local OLD_HASH="$(sha256sum $DL_DIR/${file/$VERSION/$OLD_VER})"
		local NEW_HASH="$(sha256sum $x)"
		grep -q "${OLD_HASH%% *}" $GITDIR/config/mod/dl-kernel.in || echo "Not found: $file"
		sed "s/${OLD_HASH%% *}/${NEW_HASH%% *}/" -i $GITDIR/config/mod/dl-kernel.in
	done
}


help() {
echo "Usage: $0 <vanilla2avm|vanilla4avm|generate_vanilla>"
cat <<'EOX'

        vanilla2avm - patches unpacked vanilla kernel sources 2 avm with a avmdiff
        vanilla4avm - creates avmdiff file from vanilla kernel 4 avm sources
        generate_vanilla - initial used to create avmdiff from tiny kernel pack files

        Add kernel source, create avmdiff:
        Unpack avm sources
        mkdir -p ~/vanilla
        ln -sf $(realpath sources/kernel) ~/vanilla/avm
        ~/freetz-ng/tools/vanilla.sh vanilla4avm "" "" "7590_07.50"
        upload ~/vanilla/pxz/*.patch.xz
        add hash to config/mod/dl-kernel.in
        add "7590_07.50" to config/avm/source.in
        get config name: grep KCONFIG sources/kernel/linux*/.kernelvariables
        add make/kernel/patches/*/7590_07.50/
        add make/busybox/avm/07.50-7590--busybox.config.*
        add make/kernel/configs/avm/config-*-7590_07.50
        add make/kernel/configs/freetz/config-*-7590_07.50
        make sure the kernel version exists in config/avm/kernel.in
        check if avms .config matches with provided sources

EOX
}


case "$1" in
	vanilla2avm)		shift; vanilla2avm "$@" ;;
	vanilla4avm)		shift; vanilla4avm "$@" ;;
	generate_vanilla)	shift; generate_vanilla ;;
	*)			help                    ;;
esac


rm -rf "$TEMPDIR"
exit
