#! /bin/sh
#######################################################################################################
#                                                                                                     #
# dump AVM's kernel config area from a running FRITZ!OS using a Linux kernel version 3.xx             #
#                                                                                                     #
# There are missing files in the open source packages published by AVM and it's impossible to build   #
# an own kernel, which may boot up on these devices.                                                  #
# This script is part of a solution to create a workaround, it dumps the content of the configuration #
# area to a file and other programs may be used to dissect this dump and create an assembler input    #
# file for the missing data.                                                                          #
#                                                                                                     #
#######################################################################################################
#                                                                                                     #
# Copyright (C) 2016 P.Hämmerlein (peterpawn@yourfritz.de)                                            #
#                                                                                                     #
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU  #
# General Public License as published by the Free Software Foundation; either version 2 of the        #
# License, or (at your option) any later version.                                                     #
#                                                                                                     #
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without   #
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      #
# General Public License under http://www.gnu.org/licenses/gpl-2.0.html for more details.             #
#                                                                                                     #
#######################################################################################################
#                                                                                                     #
# constants                                                                                           #
#                                                                                                     #
#######################################################################################################
prefix="__avm_kernel_config_"
symbols="end start"
source="/proc/kallsyms"
memory="/dev/mem"
align=4096
#######################################################################################################
#                                                                                                     #
# assure redirected STDOUT descriptor                                                                 #
#                                                                                                     #
#######################################################################################################
if [ -t 1 ]; then
	printf "Memory dump will be written to STDOUT, please redirect it to any location.\n" 1>&2
	exit 1
fi
#######################################################################################################
#                                                                                                     #
# read symbols from kernel and do some basic checks                                                   #
#                                                                                                     #
#######################################################################################################
for s in $symbols; do unset $s; loc="${loc}${loc:+\\|}$s"; done
eval $(sed -n -e "s|^\([0-9A-Fa-f]\{8\}\) . $prefix\(\($loc\)\)|\2=0x\1|p" $source)
for s in $symbols; do
	eval v=\$$s
	if [ -z $s ]; then
		printf "Unable to locate $prefix$s symbol.\n" 1>&2
		exit 1
	else
		if [ $(( v % align )) -ne 0 ]; then
			printf "Unexpected alignment of symbol $prefix$s.\n" 1>&2
			exit 1
		fi
	fi
done
#######################################################################################################
#                                                                                                     #
# check area size and compute number of blocks to skip and to copy                                    #
#                                                                                                     #
#######################################################################################################
set -- $symbols
len=$(( $1 - $2 ))
if [ $len -le 0 ]; then
	printf "Computed config area size is invalid.\n" 1>&2
	exit 1
fi
skip=$(( ($2 & 0x1FFFFFFF) / align ))
count=$(( len / align ))
#######################################################################################################
#                                                                                                     #
# copy memory content now                                                                             #
#                                                                                                     #
#######################################################################################################
dd if=$memory bs=$align skip=$skip count=$count 2>/dev/null
rc=$?
if [ $rc -ne 0 ]; then
	printf "Error $rc copying memory content from /dev/mem.\n" 1>&2
	exit 1
fi
#######################################################################################################
#                                                                                                     #
# end of script                                                                                       #
#                                                                                                     #
#######################################################################################################
exit 0
