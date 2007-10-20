#!/bin/bash

cat << 'EOF' >> ${FILESYSTEM_MOD_DIR}/etc/profile
if [ $USER == "root" ] && grep -q '^root:$1$20WQVLFF$0Sc.MbHHNC0JaIJf6qZR1/' /etc/shadow; then
    echo
    passwd
    modusers save
    modsave flash
fi

EOF
