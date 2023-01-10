[ "$FREETZ_REMOVE_NEXUS" == "y" ] || return 0
echo1 "removing nexus files"

for files in \
  etc/init.d/e45-avmnexusd \
  etc/init.d/E45-avmnexusd \
  bin/avmnexusd \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
supervisor_delete_service "avmnexusd"

#for files in \
#  lib/avmnexus.so* \
#  lib/avmnexuscfg.so* \
#  lib/avmnexus_nocsock.so* \
#  lib/avmnexus_tab.so* \
#  etc/default.Fritz_Box_HW185/all/avmnexus*.xml \
#  usr/www/all/css/rd/images/ic_nexus.svg \
#  lib/libavmnexuscpp.so.0.0.0 \
#  lib/libavmnexusmail.so.0.0.0 \
#  ; do
#	rm_files "${FILESYSTEM_MOD_DIR}/$files"
#done

