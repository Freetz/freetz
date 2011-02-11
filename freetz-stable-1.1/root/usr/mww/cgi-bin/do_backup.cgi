#!/usr/bin/haserl -u 10000 -U /var/tmp
<?
fname=$(echo ${CONFIG_PRODUKT_NAME}_${CONFIG_VERSION_MAJOR}.${CONFIG_VERSION}${CONFIG_SUBVERSION}`date '+_%Y-%m-%d_%H%M.freetz'`|sed 's/ /_/g;s/!/./')
echo "Content-Type: application/x-gzip"
echo "Content-Disposition: attachment; filename=\"$fname\""
echo

# Create backup of all config files in /var/flash
#
# Make sure that no command accidentally writes stdout or stderr stuff into the
# output stream = gzipped tar archive. This is why you see so much output
# redirection here.

# Set working dir so tar can use relative path names
cd /var/tmp > /dev/null 2>&1

# Create empty temp-dir for backup
export BACKUP_DIR='var_flash' > /dev/null 2>&1
rm -rf $BACKUP_DIR > /dev/null 2>&1
mkdir $BACKUP_DIR > /dev/null 2>&1

# Create temporary copies of those character streams in /var/flash
for file in $(ls /var/flash); do
  cat /var/flash/$file > $BACKUP_DIR/$file 2> /dev/null
done

# Create backup and send it to client via stdout
tar cz $BACKUP_DIR/ 2> /dev/null

# Clean up
rm -rf $BACKUP_DIR > /dev/null 2>&1
?>
