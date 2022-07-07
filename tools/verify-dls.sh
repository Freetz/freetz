#!/bin/bash

#
# (c) freetz.org
#
# a simple script to verify (firmware) download-URLs
#

#
# stdin - content to search in
# $1    - menuconfig option name
#
extract_menuconfig_defaults() {
	sed -r -n \
	-e '/^[ \t]*config[ \t]+'"$1"'[ \t]*$/,/^[ \t]*config[ \t]+.*$/ {
		//! {
			s,^[ \t]*default[ \t]+(.*),\1,p
		}
	}'
}

normalize_white_spaces() {
	sed -r -e 's/[\t]+/ /g' -e 's/[ ]{2,}/ /g'  -e 's/^[ ]+//' -e 's/[ ]+$//' -e 's/(!) /\1/g' -e 's/ ([)])/\1/g'
}

limit_to() {
	sed -r -n -e '/'"$1"'/ {s, && '"$1"',,p;s,'"$1"' && ,,p;}'
}

to_associative_array() {
	sed -r -e 's,^"([^"]*)" (.*),["\2"]="\1",'
}

#
# $1 - "site" menuconfig symbol (e.g. FREETZ_DL_SITE)
# $2 - "filename" menuconfig symbol (e.g. FREETZ_DL_SOURCE)
# $3 - filter symbol (e.g. FREETZ_TYPE_FIRMWARE_FINAL)
#
extract_urls() {
	local site_symbol="$1" filename_symbol="$2" filter_symbol="$3"
	local menuconfigfile= site= filename= condition=

	menuconfigfile="./config/mod/dl-firmware.in"
	if [ ! -f "$menuconfigfile" ]; then
		echo >&2 "Menuconfig file \"$file\" not found."
		exit 1
	fi

	eval "local -A sites=($(cat "${menuconfigfile}" | extract_menuconfig_defaults "${site_symbol}" | normalize_white_spaces | limit_to "${filter_symbol}" | to_associative_array))"
	eval "local -A filenames=($(cat "${menuconfigfile}" | extract_menuconfig_defaults "${filename_symbol}" | normalize_white_spaces | limit_to "${filter_symbol}" | to_associative_array))"

	if [ ${#sites[@]} != ${#filenames[@]} ]; then
		echo >&2 "Inconsistent ${site_symbol} and "${filename_symbol}" values"
		exit 1
	fi

	for condition in "${!filenames[@]}"; do
		filename=$(echo ${filenames["$condition"]} | cut -d '/' -f 2)
		site=${sites["$condition"]}
		if [ -z "${site}" ]; then
			echo >&2 "No ${site_symbol}-entry for \"${filename}\" found."
			exit 1
		fi
		echo -e "${site}\t${filename}"
	done | sort -t $'\t' -f -k 2
}

check_urls() {
	local line= site= filename= dl_tool=./tools/freetz_download
	local -i c=0 c_failed=0 total=0

	if [ ! -x "${dl_tool}" ]; then
		echo >&2 "Freetz-download-tool (${dl_tool}) not found."
		exit 1
	fi

	total=$(echo "$1" | wc -l)
	echo "Found ${total} URLs"

	while read line; do
		c=$((c+1))
		filename=$(echo "${line}" | cut -d $'\t' -s -f 2)
		site=$(echo "${line}" | cut -d $'\t' -s -f 1)

		echo -ne "${c}/${total} ${filename} <-- ${site} ... "
		if ${dl_tool} --no-append-servers check "${filename}" "${site}"; then
			echo OK
		else
			echo FAILED
			c_failed=$((c_failed+1))
		fi
	done <<< "${1}"

	if [ "${c_failed}" -gt 0 ]; then
		echo >&2 "Warning: ${c_failed} out of ${total} downloads failed."
	fi
}

final_firmwares="$(extract_urls FREETZ_DL_SITE FREETZ_DL_SOURCE FREETZ_TYPE_FIRMWARE_FINAL)"
labor_firmwares="$(extract_urls FREETZ_DL_SITE FREETZ_DL_SOURCE_CONTAINER FREETZ_TYPE_FIRMWARE_LABOR)"

check_urls "$(echo -e "${final_firmwares}\n${labor_firmwares}")"
