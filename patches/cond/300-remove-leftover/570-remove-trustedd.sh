[ "$FREETZ_AVM_VERSION_07_2X" == "y" ] || return 0
echo1 "removing trustedd"

supervisor_remove_dependency "trustedd"

