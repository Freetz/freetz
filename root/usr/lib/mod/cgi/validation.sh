# validate various types of data
valid() {
	local type=$1 data=$2
	case $type in
		package|id)
			case $data in
				*[^a-zA-Z0-9-_]*) return 1 ;;
				*) return 0 ;;
			esac
			;;
	esac
	return 1
}
