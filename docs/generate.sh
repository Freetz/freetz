#!/bin/bash
# generates everything with docs/*/generate.sh
MYPWD="$(dirname $(realpath $0))"

[ -z "$(locale charmap | grep -i '^Utf-*8$')" ] && echo "Setting 'locale' to EN" && export LANG=en_US.utf8
[ -z "$(locale charmap | grep -i '^Utf-*8$')" ] && echo "Setting 'locale' to DE" && export LANG=de_DE.UTF-8
[ -z "$(locale charmap | grep -i '^Utf-*8$')" ] && echo "You have no UTF8 'locale' installed." && exit 1

generate_info() {
[ -e "$MYPWD/$2" ] && echo -e "\n$1:" && "$MYPWD/$2" && echo "done."
}

generate_warn() {
generate_info $@ 2>&1 | grep -v '^nohelp'
}

generate_warn "Packages"       "make/generate.sh"
generate_warn "Libraries"      "libs/generate.sh"
generate_warn "Patches"        "patches/generate.sh"
generate_info "Wiki"           "wiki/generate.sh"
generate_info "Screenshots"    "screenshots/generate.sh"
generate_info "Prerequisites"  "PREREQUISITES/generate.sh"
echo

