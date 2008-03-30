#!/var/tmp/sh
############################################################
## Reverse lookup with phonebook.txt and userscript-event
##
## The phonebook.txt is in the dtmfbox directory and has
## the following format:
## number|name
## 123456|any name
## 333322|any other name
##
## When phonebook lookup failed, a userscript event 
## is called ($SCRIPT="INVERS") so you can do your own
## lookups.
############################################################
NUMBER="$1"

# lookup phonebook.txt
PHONEBOOK_ENTRY=`cat ./phonebook.txt | grep "^$NUMBER|" | $HEAD -n 1`
if [ "$PHONEBOOK_ENTRY" != "" ]; 
then
	echo "$PHONEBOOK_ENTRY" | sed 's/^.*|\(.*\)$/\1/g'

# otherwise when lookup failed, call userscript ($SCRIPT="INVERS")
else
	if [ -f "$USERSCRIPT" ]; 
	then
		SCRIPT="INVERS"
		. "$USERSCRIPT"
		if [ "$?" = "1" ]; then exit 1; fi
	fi
fi
