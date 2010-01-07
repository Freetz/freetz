#!/bin/sh
echo -e "Content-type: text/html; charset=iso-8859-1\n\n"
uudecode /usr/share/about.txt -o - | bzcat
