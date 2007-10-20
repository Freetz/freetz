#!/bin/bash

cat << 'EOF' >> ${FILESYSTEM_MOD_DIR}/etc/profile
if [ $USER == "root" ] && grep -q '^root:$1$9trcFt52$m6sHT4qeLllv0v9YJ2yV2/' /etc/shadow; then
    echo
    passwd
    modusers save
    modsave flash
fi

EOF
