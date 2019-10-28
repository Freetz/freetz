#!/bin/bash
# generates everything with README/*/generate.sh
MYPWD="$(dirname $(realpath $0))"

generate_info() {
[ -e "$MYPWD/$2" ] && echo -e "\n$1:" && "$MYPWD/$2" && echo "done."
}

generate_warn() {
generate_info $@ 2>&1 | grep -v '^nohelp'
}

generate_warn "Packages"    "make/generate.sh"
generate_warn "Libraries"   "libs/generate.sh"
generate_warn "Patches"     "patches/generate.sh"
generate_info "Wiki"        "wiki/generate.sh"
generate_info "Screenshots" "screenshots/generate.sh"
echo

