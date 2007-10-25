#!/bin/bash

cat << 'EOF' >> ${FILESYSTEM_MOD_DIR}/etc/profile
if [ $USER == "root" ] && grep -q '^root:$1$$zla3yqbLURbyMO/5ZvHBR0' /etc/shadow; then
    echo "Default password detected. Please enter a new passsword for 'root'."
    passwd
    modusers save
    modsave flash
fi
EOF
