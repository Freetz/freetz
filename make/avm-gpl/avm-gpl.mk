AVM_SITE__AVM:=ftp://ftp.avm.de/develper/opensrc
AVM_SITE__TCOM:=http://www.t-home.de/dlp/eki/downloads/Speedport

AVM_SOURCE__04.29:=$(AVM_SITE__AVM)/fritzbox-source-files-04.29.tar.bz2
AVM_SOURCE__04.30:=$(AVM_SITE__AVM)/fritzbox7141-source-files-04.30.tar.bz2
AVM_SOURCE__04.33:=$(AVM_SITE__AVM)/fritzbox-source-files-04.33.tar.bz2
AVM_SOURCE__04.40:=$(AVM_SITE__AVM)/fritzbox-source-files.04.40.tar.bz2
AVM_SOURCE__04.49:=$(AVM_SITE__AVM)/fritzbox7270-source-files-current.tar.gz
AVM_SOURCE__r4884:=$(AVM_SITE__TCOM)/Speedport%20W%20900V/GPL-r4884-8mb_26-tar.bz2
AVM_SOURCE__r7203:=$(AVM_SITE__TCOM)/Speedport_W501V/GPL-r7203-4mb_26-tar.bz2
AVM_SOURCE__r8508:=$(AVM_SITE__TCOM)/Speedport%20W%20701%20V/GPL-r8508-8mb_26.tar.bz2

AVM_URL:=$(AVM_SOURCE__$(AVM_VERSION))
AVM_SOURCE:=$(notdir $(AVM_URL))
AVM_SITE:=$(dir $(AVM_URL))

AVM_DIR:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)

AVM_UNPACK__INT_.gz:=z
AVM_UNPACK__INT_.bz2:=j

$(DL_DIR)/$(AVM_SOURCE): | $(DL_DIR)
	wget --passive-ftp -P $(DL_DIR) $(AVM_SITE)/$(AVM_SOURCE)

$(AVM_DIR)/.unpacked: $(DL_DIR)/$(AVM_SOURCE)
	mkdir -p $(AVM_DIR)
	tar -C $(AVM_DIR) $(VERBOSE) -x$(AVM_UNPACK__INT_$(suffix $(strip $(AVM_SOURCE))))f $(DL_DIR)/$(AVM_SOURCE)
ifeq ($(AVM_VERSION),04.49)
	mkdir -p $(AVM_DIR)/GPL/base/kernel
	tar -C $(AVM_DIR)/GPL/base/kernel $(VERBOSE) -xzf $(AVM_DIR)/GPL/GPL-release_kernel.tar.gz
endif
	touch $@

avm-gpl-precompiled: $(AVM_DIR)/.unpacked

avm-gpl-source: $(AVM_DIR)/.unpacked

avm-gpl-clean:

avm-gpl-dirclean:
	rm -rf $(AVM_DIR)
