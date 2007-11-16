#!/bin/bash -x

echo1 "Applying symlinks, deleting additional webinterfaces"
rm -rf ${FILESYSTEM_MOD_DIR}/usr/www/1und1 ${FILESYSTEM_MOD_DIR}/usr/www/freenet
mv ${FILESYSTEM_MOD_DIR}/usr/www/avm ${FILESYSTEM_MOD_DIR}/usr/www/all
ln -s all ${FILESYSTEM_MOD_DIR}/usr/www/avm
ln -s all ${FILESYSTEM_MOD_DIR}/usr/www/1und1
ln -s all ${FILESYSTEM_MOD_DIR}/usr/www/freenet