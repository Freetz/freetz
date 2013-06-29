#!/bin/bash
#cuma, 2013-06-29
#rubbish script to verify download-urls

gen_files() {

	nmbr=$(cat Config.in | wc -l)

	config=FREETZ_DL_SITE
	pathS=$(cat Config.in |nl -ba| sed -n "s/^ *\([0-9]*\).*config $config$/\1/p")
	pathE=$(cat Config.in | tail -n $(($nmbr-$pathS+1)) |nl -ba | sed -n "s/^ *\([0-9]*\)\t$/\1/p"|head -n1)

	config=FREETZ_DL_SOURCE
	fileS=$(cat Config.in |nl -ba| sed -n "s/^ *\([0-9]*\).*config $config$/\1/p")
	fileE=$(cat Config.in | tail -n $(($nmbr-$fileS+1)) |nl -ba | sed -n "s/^ *\([0-9]*\)\t$/\1/p"|head -n1)

	config=FREETZ_DL_SOURCE_MD5
	md5sS=$(cat Config.in |nl -ba| sed -n "s/^ *\([0-9]*\).*config $config$/\1/p")
	md5sE=$(cat Config.in | tail -n $(($nmbr-$md5sS+1)) |nl -ba | sed -n "s/^ *\([0-9]*\)\t$/\1/p"|head -n1)

#	echo $nmbr
#	echo "$pathS -- $pathS"
#	echo "$fileS -- $fileS"
#	echo "$md5sS -- $md5sS"
#	echo

	cat Config.in | tail -n $(($nmbr-$fileS+1)) | head -n $fileE | grep -e '^.*default "' > Config.tmp.file
	cat Config.in | tail -n $(($nmbr-$pathS+1)) | head -n $pathE | grep -e '^.*default "' > Config.tmp.path
	cat Config.in | tail -n $(($nmbr-$md5sS+1)) | head -n $md5sE | grep -e '^.*default "' > Config.tmp.md5s

}

del_files() {
	rm -rf \
	  Config.tmp.file \
	  Config.tmp.path \
	  Config.tmp.md5s \
	  2>/dev/null
}

check_web() {
	c=0
	cnt="$(grep -vEi 'FREETZ_TYPE_CUSTOM|BETA|Labor' Config.tmp.file| sed "s/.*default \"//g" |wc -l)"
	echo -e "\nFound $cnt URLs\n"
	cat Config.tmp.file |grep -vEi "FREETZ_TYPE_CUSTOM|BETA|Labor"| sed 's/.*default "//g' | while read line; do
		let c++
		firm="${line%%\"*}"
		cond="${line#*if }"
		path="$(cat Config.tmp.path | sed -n "s/.*default \"\(.*\)\".*if $cond$/\1/p")"
		[ -z "$path" ] && echo -e "$c/$cnt $firm\nPATH\n"
		[ -z "$path" ] && continue
		full="$path/$firm"
		echo -en "$c/$cnt $full "

		if [ ${full:0:4} == "@AVM" ]; then
			full=${full/@AVM\//}
			sites[0]=http://download.avm.de/fritz.box/$full
			sites[1]=ftp://service.avm.de/$full
			sites[2]=ftp://ftp.avm.de/fritz.box/$full
			num_sites=3
		elif [ ${full:0:8} == "@TELEKOM" ]; then
			full=${full/@TELEKOM\//}
			sites[0]=http://www.telekom.de/dlp/eki/downloads/$full
			sites[1]=http://www.t-home.de/dlp/eki/downloads/$full
			sites[2]=http://hilfe.telekom.de/dlp/eki/downloads/$full
			num_sites=3
		else
			sites[0]=$full
			num_sites=1
		fi

		head=""
		for (( i=0; i<num_sites; i++ )); do
			rets="$(curl -I "${sites[$i]}" 2>/dev/null | grep '^Content-Length: .......')"
			[ -n "$rets" ] && retv="0" || retv="1"
			head="$retv$head"
			echo -n "... "
#			echo -e "\n${sites[$i]}"
			[ "${head:0:1}" == "0" ] && break
		done
		echo
		[ "$head" != "${head//0/}" ] && echo -e "$c/$cnt $rets\n" || echo -e "FAIL\n"
	done
}

if [ ! -e Config.in ]; then
	echo "File ./Config.in not found!"
	exit 1
fi

# main
gen_files
check_web
del_files


