[ "$FREETZ_REMOVE_MODULE_BINS" == "y" ] || return 0
echo1 "removing module bins"

MODULES_DIR="$(find ${FILESYSTEM_MOD_DIR}/lib/modules/[2345].[0123456789]*.* -maxdepth 0 -type d)"
rm_files \
  $MODULES_DIR/modules.alias.bin \
  $MODULES_DIR/modules.builtin.bin \
  $MODULES_DIR/modules.dep.bin \
  $MODULES_DIR/modules.symbols.bin

