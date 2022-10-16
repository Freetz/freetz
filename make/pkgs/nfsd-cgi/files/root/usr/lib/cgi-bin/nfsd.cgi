#!/bin/sh

. /usr/lib/libmodcgi.sh


#

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype "enabled" "$NFSD_ENABLED" "" "" 0

sec_end

#

sec_begin "$(lang de:"Optionen" en:"Options")"

cgi_print_checkbox_p "no_nfs_v4" "$NFSD_NO_NFS_V4" \
  "$(lang de:"NFS Version 4 nicht anbieten" en:"Do not offer NFS version 4")"

cgi_print_textline_p "mountd_port" "$NFSD_MOUNTD_PORT" 6/5 \
  "$(lang de:"Fester Port f&uuml;r mountd (leer: zuf&auml;llig)" en:"Non dynamic port for mountd (empty: random)"): "

sec_end

