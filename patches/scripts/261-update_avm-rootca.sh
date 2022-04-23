
[ -e "${FILESYSTEM_MOD_DIR}/etc/avm_root_ca.pem" ] && file="${FILESYSTEM_MOD_DIR}/etc/avm_root_ca.pem" || file="${FILESYSTEM_MOD_DIR}/etc/jasonii_root_ca.pem"
grep -q '^KUmD27BtqA==$' "$file" 2>/dev/null || return 0

echo1 "updating expired AVM-RootCA"

# replaced (public key of) avm-rootca expires 2022/01/29, since FOS ~6.30 used
# this new (public key of) avm-rootca expires 2046/04/26, since FOS ~7.29 used
# unknown for which AVM services its exactly be used on the devices
# see https://github.com/Freetz-NG/freetz-ng/discussions/424

echo2 "replacing $file"
cat "$TOOLS_DIR/avm-rootca.pem" > "$file"

