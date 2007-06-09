if [ "$DS_PATCH_INTERNATIONAL" == "y" ]
then
	# from http://www.the-construct.com/
	echo1 "applying international patch"
	sed -i -e "s/LKZ 0/LKZ 1/g" "${HTML_MOD_DIR}/fon/sip1.js"
fi
