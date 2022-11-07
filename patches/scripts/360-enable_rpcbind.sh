[ "$FREETZ_AVM_HAS_RPCBIND" == "y" ] || return 0
[ "$FREETZ_PACKAGE_NFSD_CGI" == "y" ] || return 0
echo1 "enabling rpcbind"

modsed \
  's/rpcbind -h $APP_RPC_IP/rpcbind/' \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/rpcbind_init \
  'rpcbind$'

