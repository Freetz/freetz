#!/bin/sh
usage() {
	local err_arg=255
	[ $# -gt 0 ] && [ -n "$1" ] && { echo "ERROR: double option \"$1\"!" ; err_arg=128 ; }
	echo >&2 "$(basename $0) v$VERSION Patcher for shell scripts"
	echo >&2 "Author hermann72pb <http://www.ip-phone-forum.de/member.php?u=80424>"
	echo >&2 " "
	echo >&2 "Usage: $(basename $0) FUNCTION OPERATION ARGUMENTs OPTIONs"
	echo >&2 " "
	echo >&2 " FUNCTION (one of):"
	echo >&2 " -f, --function                functions, subroutines between {...}" 
	echo >&2 " -t, --option                  an option of case in between )...;;" 
	echo >&2 " "
	echo >&2 " OPERATION (one of):"
	echo >&2 " -c, --cut                     cut found section" 
	echo >&2 " -d, --delete                  delete found section" 
	echo >&2 " -r, --replace                 replace found section" 
	echo >&2 " "
	echo >&2 " required ARGUMENTs:"
	echo >&2 " -i, --input-file FILENAME     name of input shell script file" 
	echo >&2 " -s, --section-name SECTION    name of section for the search (keyword)" 
	echo >&2 " -n, --new-string NEWSTRING    new string to replace instead of old section (only for replacement)" 
	echo >&2 " "
	echo >&2 " optional ARGUMENTs:"
	echo >&2 " -o, --output-file FILENAME    name of output shell script file" 
	echo >&2 "                               otherwise filtered output to STDOUT" 
	echo >&2 " -h, --help                    show this help" 
	echo >&2 " -------------" 
	echo >&2 " "
	return $err_arg
}

write_to_file() # write to new file
{ # write_to_file oldfile tmpfile newfile
	file_perm=$(stat -c %a $1)
	mv $2 $3
	mv_err=$?
	chmod $file_perm $3
	return $mv_err
}

check_args() # check arguments
{
	[ -r "$1" ] || return 22 # file can not be read
	[ $# -lt 3 ] && return 23 # not enough arguments
	[ -z "$1" ] && return 24 # filename not defined
	[ -z "$2" ] && return 25 # sectionname not defined
	[ -z "$3" ] && return 26 # searching function not defined
	return 0
}
find_section() # finds sections (functions, subroutines)
{ # Usage: find_section filename sectionname function
	case "$3" in
	f)
		local keyword_rows="$(sed -n '/'$2'[[:blank:]]*([[:blank:]]*)/=' $1)"
		[ -z "$keyword_rows" ] && return 21 # section not found
		local sec_begin_rows="$(sed -n '/{[^}]*$/=' $1)"
		[ -z "$sec_begin_rows" ] && return 21 # section not found
		local sec_end_rows="$(sed -n '/^[^{]*}/=' $1)"
		[ -z "$sec_end_rows" ] && return 21 # section not found
		[ -n "$keyword_rows" ] && keyword_rows=$(echo -n "$keyword_rows" | sed -n "1p")
		sec_begin_number=$(for row_number in $sec_begin_rows; do \
		if [ $((row_number)) -ge $((keyword_rows)) ]; \
		then echo "$row_number"; break; fi; done)
		sec_end_number=$(for row_number in $sec_end_rows; do \
		if [ $((row_number)) -ge $((keyword_rows)) ]; \
		then echo "$row_number"; break; fi; done)
	;;
	t)
		local keyword_rows="$(sed -n '/'$2'[[:blank:]]*)/=' $1)"
		[ -z "$keyword_rows" ] && return 21 # section not found
		local sec_end_rows="$(sed -n '/\;\;/=' $1)"
		[ -z "$sec_end_rows" ] && return 21 # section not found
		[ -n "$keyword_rows" ] && keyword_rows=$(echo -n "$keyword_rows" | sed -n "1p")
		sec_begin_number=$keyword_rows
		sec_end_number=$(for row_number in $sec_end_rows; do \
		if [ $((row_number)) -ge $((keyword_rows)) ]; \
		then echo "$row_number"; break; fi; done)
	;;
	*)
		return 28 # not defined
	;;
	esac
	[ -z $sec_begin_number ] && return 21 # section not found
	[ -z $sec_end_number ] && return 21 # section not found
	[ $sec_begin_number -gt $sec_end_number ] && return 29 # plausibility error
	return 0
}
cut_section() # cut sections (functions, subroutines)
{ # Usage: delete_section filename sectionname
	local sec_begin_number
	local sec_end_number
	check_args $*
	exval=$?
	[ $exval -eq 0 ] && { find_section $1 $2 $3 ; exval=$? ; } 
	[ $exval -eq 0 ] && { sed -n $sec_begin_number','$sec_end_number' p' "$1" > ${OUTSTRING}; exval=$? ; }
	[ $exval -eq 0 ] && { [ $# -ge 4 -a -n $4 ] && write_to_file $1 ${OUTSTRING} $4 || cat ${OUTSTRING} ; } 
	rm -f ${OUTSTRING}
	return $exval
}
delete_section() # deletes sections (functions, subroutines)
{ # Usage: delete_section filename sectionname
	local sec_begin_number
	local sec_end_number
	check_args $*
	exval=$?
	[ $exval -eq 0 ] && { find_section $1 $2 $3 ; exval=$? ; }
	[ $exval -eq 0 ] && { sed $sec_begin_number','$sec_end_number' d' "$1" > ${OUTSTRING}; exval=$? ; }
	[ $exval -eq 0 ] && { [ $# -ge 4 -a -n $4 ] && write_to_file $1 ${OUTSTRING} $4 || cat ${OUTSTRING} ; } 
	rm -f ${OUTSTRING}
	return $exval
}
replace_section() # replaces sections (functions, subroutines)
{ # Usage: replace_section filename sectionname
	[ $# -lt 4 ] && return 23 # not enough arguments
	[ -z "$4" ] && return 25 # replacement not defined
	local sec_begin_number
	local sec_end_number
	echo -n "$4" | sed -n ':a;$!N;$!ba;s/\n/\\n/g;p' > ${FILTSTRING}
	local replaced_string="$(cat ${FILTSTRING})"
	rm -f ${FILTSTRING}
	check_args $*
	exval=$?
	[ $exval -eq 0 ] && { find_section $1 $2 $3 ; exval=$? ; }
	[ $exval -eq 0 ] && { sed $sec_begin_number','$sec_end_number' d' "$1" \
	| sed $sec_begin_number'i'"$replaced_string" > ${OUTSTRING} ; exval=$? ; }
	[ $exval -eq 0 ] && { [ $# -ge 5 -a -n $5 ] && write_to_file $1 ${OUTSTRING} $5 || cat ${OUTSTRING} ; } 
	rm -f ${OUTSTRING}
	return $exval
}

VERSION="1.0"
FILTSTRING='/tmp/filtered_string'
OUTSTRING='/tmp/patcher_outstring'
unset input_file
unset output_file
unset section_name
unset new_string
unset operation
unset search_function

[ $# -lt 4 -a "$1" != "-h" -a "$1" != "--help" ] && { echo "ERROR: Not enoug arguments!\n" ; usage ; exit 1 ; }

TEMP="$(getopt -o hi:o:s:n:cdrft --long help,input-file:,output-file,section-name:,new-section:,cut,delete,replace,function,option -n $(basename $0) -- "$@")" || { usage ; exit $? ; }

eval set -- "$TEMP"
while true ; do
	case "$1" in
		-h|--help) usage ; exit $? ;;
		-i|--input-file) [ -z "$input_file" ] && { input_file="$2" ; shift 2 ; } || { usage "input file"; exit $? ; } ;;
		-o|--output-file) [ -z "$output_file" ] && { output_file="$2" ; shift 2 ; } || { usage "output file"; exit $? ; } ;;
		-s|--section-name) [ -z "$section_name" ] && { section_name="$2" ; shift 2 ; } || { usage "section name"; exit $? ; } ;;
		-n|--new-string) [ -z "$new_string" ] && { new_string="$2" ; shift 2 ; } || { usage "new string"; exit $? ; } ;;
		-c|--cut) [ -z "$operation" ] && { operation="c" ; shift ; } || { usage "operation"; exit $? ; } ;;
		-d|--delete) [ -z "$operation" ] && { operation="d" ; shift ; } || { usage "operation"; exit $? ; } ;;
		-r|--replace) [ -z "$operation" ] && { operation="r" ; shift ; } || { usage "operation"; exit $? ; } ;;
		-f|--function) [ -z "$search_function" ] && { search_function="f" ; shift ; } || { usage "search function"; exit $? ; } ;;
		-t|--option) [ -z "$search_function" ] && { search_function="t" ; shift ; } || { usage "search function"; exit $? ; } ;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

[ -z "$search_function" ] && { echo "ERROR: Searching function is not defined!\n" ; usage ; exit 2 ; }
[ -z "$operation" ] && { echo "ERROR: Searching operation is not defined!\n" ; usage ; exit 3 ; }
[ -z "$input_file" ] && { echo "ERROR: Input file is not defined!\n" ; usage ; exit 4 ; }
[ -z "$section_name" ] && { echo "ERROR: Section name is not defined!\n" ; usage ; exit 5 ; }

case $operation in
c)
	[ -n "$output_file" ] && cut_section $input_file $section_name $search_function $output_file || cut_section $input_file $section_name $search_function
	exit $?
;;
d)
	[ -n "$output_file" ] && delete_section $input_file $section_name $search_function $output_file || delete_section $input_file $section_name $search_function
	exit $?
;;
r)
	[ -z "$new_string" ] && { echo "ERROR: New string must be defined!\n" ; usage ; exit 7 ; }
	[ -n "$output_file" ] && replace_section $input_file $section_name $search_function "$new_string" $output_file || replace_section $input_file $section_name $search_function "$new_string"
	exit $?
;;
*)
	echo "ERROR: Wrong argument!\n"
	usage
	exit 9
;;
esac
