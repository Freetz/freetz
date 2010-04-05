#!/bin/sh
CR=$'\r'
echo "Content-Type: text/plain${CR}"
echo "Content-Disposition: attachment; filename=config.txt${CR}"
echo "${CR}"
cat /etc/.config
