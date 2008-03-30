#!/bin/sh

PASSW="$1"
ENTRY="$2"
NAME="$3"
NUMBER1="$4"
NUMBER2="$5"
NUMBER3="$6"

export REQUEST_METHOD="POST"
export REMOTE_ADDR="127.0.0.1"
export CONTENT_TYPE="application/x-www-form-urlencoded"
POST_DATA="login:command/password=$PASSW"
export CONTENT_LENGTH=${#POST_DATA}
echo -n "$POST_DATA" | /usr/www/html/cgi-bin/webcm > /dev/null

export REQUEST_METHOD="GET"
export REMOTE_ADDR="127.0.0.1"
export QUERY_STRING="getpage=../html/de/menus/menu2.html&var:lang=de&var:menu=fon&var:pagename=fonbuch2&var:PhonebookEntryNew=Entry$ENTRY"
cd /usr/www/html/cgi-bin
./webcm > /dev/null

if [ "$NUMBER1" != "" ]; then 
	POST_NO1="telcfg:settings/Phonebook/Entry$ENTRY/Number0/Code=1&telcfg:settings/Phonebook/Entry$ENTRY/Number0/Number=$NUMBER1&telcfg:settings/Phonebook/Entry$ENTRY/Number0/Type=home"; 
else
	POST_NO1="telcfg:settings/Phonebook/Entry$ENTRY/Number0/Code=&telcfg:settings/Phonebook/Entry$ENTRY/Number0/Number=&telcfg:settings/Phonebook/Entry$ENTRY/Number0/Type="; 
fi

if [ "$NUMBER2" != "" ]; then 
	POST_NO2="telcfg:settings/Phonebook/Entry$ENTRY/Number1/Code=2&telcfg:settings/Phonebook/Entry$ENTRY/Number1/Number=$NUMBER2&telcfg:settings/Phonebook/Entry$ENTRY/Number1/Type=mobile"; 
else
	POST_NO2="telcfg:settings/Phonebook/Entry$ENTRY/Number1/Code=&telcfg:settings/Phonebook/Entry$ENTRY/Number1/Number=&telcfg:settings/Phonebook/Entry$ENTRY/Number1/Type="; 
fi

if [ "$NUMBER3" != "" ]; then 
	POST_NO3="telcfg:settings/Phonebook/Entry$ENTRY/Number2/Code=3&telcfg:settings/Phonebook/Entry$ENTRY/Number2/Number=$NUMBER3&telcfg:settings/Phonebook/Entry$ENTRY/Number2/Type=work"; 
else
	POST_NO3="telcfg:settings/Phonebook/Entry$ENTRY/Number2/Code=&telcfg:settings/Phonebook/Entry$ENTRY/Number2/Number=&telcfg:settings/Phonebook/Entry$ENTRY/Number2/Type="; 
fi

POST_DATA="telcfg:settings/Phonebook/Entry$ENTRY/Name=$NAME&telcfg:settings/Phonebook/Entry$ENTRY/DefaultNumber=0&$POST_NO1&$POST_NO2&$POST_NO3"
export CONTENT_LENGTH=${#POST_DATA}

export REQUEST_METHOD="POST"
export REMOTE_ADDR="127.0.0.1"
echo -n "$POST_DATA" | /usr/www/html/cgi-bin/webcm > /dev/null
