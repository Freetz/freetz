#!/bin/sh
# include environment variables
[ -r /var/env.cache ] && . /var/env.cache

fname=$(echo ${CONFIG_PRODUKT_NAME}_${CONFIG_VERSION_MAJOR}.${CONFIG_VERSION}${CONFIG_SUBVERSION}$(date '+_%Y-%m-%d_%H%M.freetz') | tr ' !' '_.')
echo "Content-Type: application/x-gzip"
echo "Content-Disposition: attachment; filename=\"$fname\""
echo

# Create backup of all config files in /var/flash
#
# Make sure that no command accidentally writes stdout or stderr stuff into the
# output stream = gzipped tar archive. File descriptor 3 is the real output.
#
exec 3>&1 > /dev/null 2>&1

# Set working dir so tar can use relative path names
cd /var/tmp

# Create empty temp-dir for backup
BACKUP_DIR='var_flash'
rm -rf $BACKUP_DIR
mkdir $BACKUP_DIR

# Create temporary copies of those character streams in /var/flash
for file in $(ls /var/flash); do
  cat /var/flash/$file > $BACKUP_DIR/$file
done

# Create backup and send it to client via stdout
tar cz $BACKUP_DIR/ >&3

# Clean up
rm -rf $BACKUP_DIR
