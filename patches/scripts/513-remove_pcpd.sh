[ "$FREETZ_REMOVE_PCPD" == "y" ] || return 0
echo1 "removing pcpd files"

for files in \
  bin/pcpcsocktest \
  bin/pcptest \
  sbin/pcpd \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
supervisor_delete_service "pcpd"

# bin/showpcpitems \
# bin/showpcpinfo \
# bin/pcplisten \

