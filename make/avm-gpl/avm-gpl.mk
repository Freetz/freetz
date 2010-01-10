AVM_SITE__AVM:=@AVM/develper/opensrc
AVM_SITE__AVM_3270:=@AVM/fritz.box/fritzbox.wlan_3270/x_misc/opensrc
AVM_SITE__AVM_7270:=@AVM/fritz.box/fritzbox.fon_wlan_7270/x_misc/opensrc
AVM_SITE__AVM_7170:=@AVM/fritz.box/fritzbox.fon_wlan_7170/x_misc/opensrc
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

AVM_SOURCE_MD5__04.33:=99b6a701f9cd09319086c8655fced242
AVM_SOURCE_MD5__04.40:=008ecd257e584fc5bbf5e276d4b03ff1
AVM_SOURCE_MD5__04.49:=e6889745b437bde0f5bdb5ada93c913d
AVM_SOURCE_MD5__04.57:=702f4adf12638bfa34a6b10c0ede4b55
AVM_SOURCE_MD5__04.67:=ec2c233bb836e822d9018fd41e123a91
AVM_SOURCE_MD5__04.70:=855d4ad80fc894d9dff52fcaf55d3c12
AVM_SOURCE_MD5__04.76:=4ffc088502c896c11931ba81536fa0e6
AVM_SOURCE_MD5__3270_04.76:=13c932630682bb427c8fc9f6931775d7
AVM_SOURCE_MD5__7270_04.80:=bcd49b28a54293e1481b8170b07245e0
AVM_SOURCE_MD5__r7203:=582c74f0959a687c41c1bcfa599ace9c

AVM_URL:=$(AVM_SOURCE__$(AVM_VERSION))
AVM_SOURCE:=$(notdir $(AVM_URL))
AVM_SITE:=$(dir $(AVM_URL))
AVM_MD5:=$(AVM_SOURCE_MD5__$(AVM_VERSION))

AVM_DIR:=$(SOURCE_DIR)/kernel/avm-gpl-$(AVM_VERSION)

AVM_UNPACK__INT_.gz:=z
AVM_UNPACK__INT_.bz2:=j

$(DL_FW_DIR)/$(AVM_SOURCE): | $(DL_FW_DIR)
	$(DL_TOOL) $(DL_FW_DIR) .config $(AVM_SOURCE) $(AVM_SITE) $(AVM_MD5)

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
