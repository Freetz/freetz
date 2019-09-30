[ "$FREETZ_REMOVE_NEXUS" == "y" ] || return 0
echo1 "removing nexus files"
for files in \
  lib/systemd/system/avmnexusd.service \
  etc/init.d/e45-avmnexusd \
  etc/init.d/E45-avmnexusd \
  bin/avmnexusd \
  usr/www/all/css/rd/images/ic_nexus.svg \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

#for files in \
#  lib/avmnexus.so* \
#  lib/avmnexuscfg.so* \
#  lib/avmnexus_nocsock.so* \
#  lib/avmnexus_tab.so* \
#  etc/default.Fritz_Box_HW185/all/avmnexus*.xml \
#  ; do
#	rm_files "${FILESYSTEM_MOD_DIR}/$files"
#done

[ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] && for files in \
  lib/systemd/system/meshd_config.service \
  lib/systemd/system/meshd.service \
  etc/init.d/E48-mesh \
  sbin/meshd \
  lib/libmesh_shared.so \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

#[ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] && for files in \
#  etc/init.d/E50-plcd \
#  usr/sbin/plcd \
#  lib/libmesh_plcservice.so \
#  ; do
#       rm_files "${FILESYSTEM_MOD_DIR}/$files"
#done

#[ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] && for files in \
#  lib/libavmnexuscpp.so.0.0.0 \
#  lib/libavmnexusmail.so.0.0.0 \
#  ; do
#	rm_files "${FILESYSTEM_MOD_DIR}/$files"
#done

