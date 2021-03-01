[ "$FREETZ_REMOVE_DSL_CONTROL" == "y" ] || return 0
echo1 "removing dsl_control"

for files in \
  usr/sbin/vr10/dsl_control \
  usr/sbin/dsl_control \
  usr/sbin/dsl_pipe \
  usr/sbin/dpm_manager \
  usr/sbin/eth_oam \
  usr/sbin/oamd \
  etc/dsl/ \
  usr/sbin/dsl_monitor \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

