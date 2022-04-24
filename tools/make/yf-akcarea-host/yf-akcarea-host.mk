YF_AKCAREA_HOST_SRC:=$(TOOLS_DIR)/make/yf-akcarea-host/src
YF_AKCAREA_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yf-akcarea-host

YF_AKCAREA_HOST_TOOLS:=extract bin2asm
YF_AKCAREA_HOST_TOOLS_BUILD_DIR:=$(YF_AKCAREA_HOST_TOOLS:%=$(YF_AKCAREA_HOST_DIR)/avm_kernel_config.%)
YF_AKCAREA_HOST_TOOLS_TARGET_DIR:=$(YF_AKCAREA_HOST_TOOLS:%=$(TOOLS_DIR)/avm_kernel_config.%)


yf-akcarea-host-unpacked: $(YF_AKCAREA_HOST_DIR)/.unpacked
$(YF_AKCAREA_HOST_DIR)/.unpacked: $(wildcard $(YF_AKCAREA_HOST_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(YF_AKCAREA_HOST_DIR)
	mkdir -p $(YF_AKCAREA_HOST_DIR)
	$(call COPY_USING_TAR,$(YF_AKCAREA_HOST_SRC),$(YF_AKCAREA_HOST_DIR))
	touch $@

$(YF_AKCAREA_HOST_TOOLS_BUILD_DIR): $(YF_AKCAREA_HOST_DIR)/.unpacked $(DTC_LIBFDT_HOST_DIR)/libfdt.a
	$(MAKE) -C $(YF_AKCAREA_HOST_DIR) \
		OPT="-O0" \
		CC="$(TOOLS_CC)" \
		BITNESS="$(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LIBFDT_DIR=$(DTC_LIBFDT_HOST_DIR) \
		$(YF_AKCAREA_HOST_TOOLS:%=avm_kernel_config.%) \
		$(QUIET)
	touch -c $@

$(YF_AKCAREA_HOST_TOOLS_TARGET_DIR): $(TOOLS_DIR)/avm_kernel_config.%: $(YF_AKCAREA_HOST_DIR)/avm_kernel_config.%
	$(INSTALL_FILE)

yf-akcarea-host-precompiled: $(YF_AKCAREA_HOST_TOOLS_TARGET_DIR)


yf-akcarea-host-clean:
	-$(MAKE) -C $(YF_AKCAREA_HOST_DIR) clean

yf-akcarea-host-dirclean:
	$(RM) -r $(YF_AKCAREA_HOST_DIR)

yf-akcarea-host-distclean: yf-akcarea-host-dirclean
	$(RM) $(YF_AKCAREA_HOST_TOOLS_TARGET_DIR)

