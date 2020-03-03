[ "$FREETZ_TARGET_ARCH_X86" == "y" ] || return 0
[ "$FREETZ_REMOVE_DECT" == "y" ] && return 0

echo1 "fixing start_dect_update.sh (atom)"
modsed -r \
  's/^([ \t]*local mps=`)(mount)(.*)/\1rpc \2 | grep -v \/var\/nfsv4\3/g' \
  "${FILESYSTEM_MOD_DIR}/sbin/start_dect_update.sh" \
  "rpc mount"

