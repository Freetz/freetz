AVM_SITE__AVM:=ftp://ftp.avm.de/develper/opensrc
AVM_SITE__AVM_3270:=ftp://ftp.avm.de/fritz.box/fritzbox.wlan_3270/x_misc/opensrc
AVM_SITE__AVM_7270:=ftp://ftp.avm.de/fritz.box/fritzbox.fon_wlan_7270/x_misc/opensrc
AVM_SITE__TCOM:=http://www.t-home.de/dlp/eki/downloads/Speedport

AVM_SOURCE__04.33:=$(AVM_SITE__AVM)/fritzbox-source-files-04.33.tar.bz2
AVM_SOURCE__04.40:=$(AVM_SITE__AVM)/fritzbox-source-files.04.40.tar.bz2
AVM_SOURCE__04.49:=$(AVM_SITE__AVM)/fritzbox-source-files-04.49.tar.gz
AVM_SOURCE__04.57:=$(AVM_SITE__AVM)/fritzbox-source-files.04.57.tar.gz
AVM_SOURCE__04.67:=$(AVM_SITE__AVM)/fritzbox-source-files.04.67.tar.gz
AVM_SOURCE__04.70:=$(AVM_SITE__AVM)/fritzbox-source-files-04.70.tar.gz
AVM_SOURCE__04.76:=$(AVM_SITE__AVM_7170)/fritzbox7170-source-files-04.76.tar.gz
AVM_SOURCE__3270_04.76:=$(AVM_SITE__AVM_3270)/GPL-Fritz_Box_3270.tar.gz
AVM_SOURCE__7270_04.80:=$(AVM_SITE__AVM_7270)/fritzbox7270-source-files-04.80.tar.gz
AVM_SOURCE__r7203:=$(AVM_SITE__TCOM)/Speedport_W501V/GPL-r7203-4mb_26-tar.bz2

AVM_URL:=$(AVM_SOURCE__$(AVM_VERSION))
AVM_SOURCE:=$(notdir $(AVM_URL))
AVM_SITE:=$(dir $(AVM_URL))

AVM_DIR:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)

AVM_UNPACK__INT_.gz:=z
AVM_UNPACK__INT_.bz2:=j

$(DL_FW_DIR)/$(AVM_SOURCE): | $(DL_FW_DIR)
	wget --passive-ftp -P $(DL_FW_DIR) $(AVM_SITE)$(AVM_SOURCE)

$(AVM_DIR)/.unpacked: $(DL_FW_DIR)/$(AVM_SOURCE)
	mkdir -p $(AVM_DIR)
	tar -C $(AVM_DIR) $(VERBOSE) -x$(AVM_UNPACK__INT_$(suffix $(strip $(AVM_SOURCE))))f $(DL_FW_DIR)/$(AVM_SOURCE)
	if test -e $(AVM_DIR)/GPL/GPL-release_kernel.tar.gz; then \
		mkdir -p $(AVM_DIR)/GPL/base/kernel; \
		tar -C $(AVM_DIR)/GPL/base/kernel $(VERBOSE) -xzf $(AVM_DIR)/GPL/GPL-release_kernel.tar.gz; \
	fi
	touch $@

avm-gpl-precompiled: $(AVM_DIR)/.unpacked

avm-gpl-source: $(AVM_DIR)/.unpacked

avm-gpl-clean:

avm-gpl-dirclean:
	rm -rf $(AVM_DIR)
