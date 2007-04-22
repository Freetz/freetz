ifeq ($(AVM_VERSION),04.01)
AVM_SOURCE_SUFFIX:=gz
else
AVM_SOURCE_SUFFIX:=bz2
endif
ifeq ($(AVM_VERSION),04.15)
AVM_SOURCE_PREFIX:=7141
endif
ifeq ($(AVM_VERSION),04.19)
AVM_SOURCE_PREFIX:=-lab
endif

AVM_SOURCE:=fritzbox$(AVM_SOURCE_PREFIX)-source-files-$(AVM_VERSION).tar.$(AVM_SOURCE_SUFFIX)
AVM_SITE:=ftp://ftp.avm.de/develper/opensrc
AVM_DIR:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)

$(DL_DIR)/$(AVM_SOURCE):
	wget --passive-ftp -P $(DL_DIR) $(AVM_SITE)/$(AVM_SOURCE)

$(AVM_DIR)/.unpacked: $(DL_DIR)/$(AVM_SOURCE)
	mkdir -p $(AVM_DIR)
ifeq ($(AVM_SOURCE_SUFFIX),bz2)
	tar -C $(AVM_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(AVM_SOURCE)
else
	tar -C $(AVM_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(AVM_SOURCE)
endif
	touch $@

avm-gpl-precompiled: $(AVM_DIR)/.unpacked 

avm-gpl-source: $(AVM_DIR)/.unpacked

avm-gpl-clean:

avm-gpl-dirclean:
	rm -rf $(AVM_DIR)
