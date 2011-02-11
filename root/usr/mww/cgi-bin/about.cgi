#!/bin/sh
echo -en "Content-Type: text/html; charset=ISO-8859-1\r\n\r\n"
uudecode /usr/share/about.txt -o - | zcat
