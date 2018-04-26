# AKC stands for AVM_KERNEL_CONFIG
YOURFRITZ_AKC_HOST_SRC:=$(TOOLS_DIR)/make/yourfritz-akc-host/src
YOURFRITZ_AKC_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yourfritz-akc-host

YOURFRITZ_AKC_HOST_TOOLS:=extract bin2asm
YOURFRITZ_AKC_HOST_TOOLS_BUILD_DIR:=$(YOURFRITZ_AKC_HOST_TOOLS:%=$(YOURFRITZ_AKC_HOST_DIR)/avm_kernel_config.%)
YOURFRITZ_AKC_HOST_TOOLS_TARGET_DIR:=$(YOURFRITZ_AKC_HOST_TOOLS:%=$(TOOLS_DIR)/avm_kernel_config.%)

yourfritz-akc-host-unpacked: $(YOURFRITZ_AKC_HOST_DIR)/.unpacked
$(YOURFRITZ_AKC_HOST_DIR)/.unpacked: $(wildcard $(YOURFRITZ_AKC_HOST_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(YOURFRITZ_AKC_HOST_DIR)
	mkdir -p $(YOURFRITZ_AKC_HOST_DIR)
	$(call COPY_USING_TAR,$(YOURFRITZ_AKC_HOST_SRC),$(YOURFRITZ_AKC_HOST_DIR))
	touch $@

$(YOURFRITZ_AKC_HOST_TOOLS_BUILD_DIR): $(YOURFRITZ_AKC_HOST_DIR)/.unpacked $(DTC_LIBFDT_HOST_DIR)/libfdt.a
	$(MAKE) -C $(YOURFRITZ_AKC_HOST_DIR) \
		CC="$(TOOLS_CC)" \
		BITNESS="$(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LIBFDT_DIR=$(DTC_LIBFDT_HOST_DIR) \
		$(YOURFRITZ_AKC_HOST_TOOLS:%=avm_kernel_config.%)
	touch -c $@

$(YOURFRITZ_AKC_HOST_TOOLS_TARGET_DIR): $(TOOLS_DIR)/avm_kernel_config.%: $(YOURFRITZ_AKC_HOST_DIR)/avm_kernel_config.%
	$(INSTALL_FILE)

yourfritz-akc-host: $(YOURFRITZ_AKC_HOST_TOOLS_TARGET_DIR)

yourfritz-akc-host-clean:
	-$(MAKE) -C $(YOURFRITZ_AKC_HOST_DIR) clean

yourfritz-akc-host-dirclean:
	$(RM) -r $(YOURFRITZ_AKC_HOST_DIR)

yourfritz-akc-host-distclean: yourfritz-akc-host-dirclean
	$(RM) $(YOURFRITZ_AKC_HOST_TOOLS_TARGET_DIR)
