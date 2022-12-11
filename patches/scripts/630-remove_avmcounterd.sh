[ "$FREETZ_REMOVE_AVMCOUNTERD" == "y" ] || return 0
echo1 "removing AVMCOUNTERD files"

for file in \
  bin/supportdata.avmcounterd \
  sbin/avmcounterd \
  usr/share/avmcounterd/ \
  lib/libavmcounterd_module.so* \
  lib/libkavmcounterd.so* \
  lib/libavmrrdtoolapi.so* \
  lib/libavmrrdstate.so* \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$file"
done

supervisor_delete_service "avmcounterd"

