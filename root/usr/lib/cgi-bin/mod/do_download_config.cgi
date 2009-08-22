#!/bin/sh
echo "Content-Type: text/plain"
echo "Content-Disposition: attachment; filename=config.txt"
echo
cat /etc/.config
