#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/mod/sbin:/mod/bin:/mod/usr/sbin:/mod/usr/bin

exec 1> /tmp/fw_update.log 2>&1
alias indent="sed 's/^/  /'"

if [ "$NAME" = "stop_avm" ]; then
	echo "Stopping AVM services, part 1 (prepare_fwupgrade start) ..."
	prepare_fwupgrade start 2>&1 | indent
	echo "DONE"
	echo "</pre><pre>"
fi

echo "Extracting firmware archive ..."
tar_log="$(cat "$1" | tar -C / -xv 2>&1)"
result=$?
echo "$tar_log" | indent
if [ $result -ne 0 ]; then
	echo "FAILED"
	exit 1
fi
echo "DONE"

if [ "$NAME" = "stop_avm" ]; then
	echo "</pre><pre>"
	echo "Stopping AVM services, part 2 (prepare_fwupgrade end) ..."
	prepare_fwupgrade end 2>&1 | indent
	echo "DONE"
fi

echo "</pre><pre>"
echo "Executing firmware installation script /var/install ..."
if [ ! -x /var/install ]; then
	echo "FAILED - installation script not found or not executable."
	echo
	echo "Resuming without reboot."
	echo "You may want to clean up the extracted files."
	exit 1
fi
# Remove no-op original from var.tar
rm -f /var/post_install
inst_log="$(/var/install 2>&1)"
result=$?
echo "$inst_log" | indent
unset inst_log
case $result in
	0) result_txt="INSTALL_SUCCESS_NO_REBOOT" ;;
	1) result_txt="INSTALL_SUCCESS_REBOOT" ;;
	2) result_txt="INSTALL_WRONG_HARDWARE" ;;
	3) result_txt="INSTALL_KERNEL_CHECKSUM" ;;
	4) result_txt="INSTALL_FILESYSTEM_CHECKSUM" ;;
	5) result_txt="INSTALL_URLADER_CHECKSUM" ;;
	6) result_txt="INSTALL_OTHER_ERROR" ;;
	7) result_txt="INSTALL_FIRMWARE_VERSION" ;;
	8) result_txt="INSTALL_DOWNGRADE_NEEDED" ;;
	*) result_txt="unknown error code" ;;
esac
echo "DONE - installation script return code = $result ($result_txt)"

echo "</pre><pre>"
echo "Generated content of /var/post_install:"
if [ ! -x /var/post_install ]; then
	echo "NONE - post-installation script not found or not executable."
	exit 1
fi
cat /var/post_install | indent
echo "END OF FILE"
echo
echo "The post-installation script will be executed upon reboot and perform"
echo "the actions specified therein, e.g. the actual firmware flashing."
echo "You may still choose to interrupt this process by removing the script"
echo "along with the rest of the extracted firmware components."
