[ "$FREETZ_REMOVE_MESHD" == "y" ] || return 0
echo1 "removing meshd files"

for files in \
  etc/init.d/E48-mesh \
  etc/init.d/E51-mesh \
  sbin/meshd \
  usr/sbin/meshd \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
supervisor_delete_service "meshd_config"
supervisor_delete_service "meshd"

# lib/libmesh_shared.so \

