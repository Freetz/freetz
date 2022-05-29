[ "$FREETZ_PATCH_FAXPAGES" == "y" ] || return 0
echo1 "enabling multiple-fax-pages"

for oem in $(supported_brandings) all; do
   [ -d "${FILESYSTEM_MOD_DIR}/usr/www/${oem}" -a ! -L "${FILESYSTEM_MOD_DIR}/usr/www/${oem}" ] || continue

   for file in /usr/www/${oem}/fon_devices/fax_send.lua; do
       [ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
           modsed \
             's/accept="image\/\*">/accept="image\/\*" multiple="multiple">/' \
             ${FILESYSTEM_MOD_DIR}${file} \
             'multiple="multiple">'
   done
done

