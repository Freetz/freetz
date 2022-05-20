$(call TOOL_INIT, 0)

$(TOOL)_BINS:=extract bin2asm
$(TOOL)_BUILD_DIR:=$($(TOOL)_BINS:%=$($(TOOL)_DIR)/avm_kernel_config.%)
$(TOOL)_TARGET_DIR:=$($(TOOL)_BINS:%=$(TOOLS_DIR)/avm_kernel_config.%)

$(TOOL)_DEPENDS:=sfk-host


$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(wildcard $($(TOOL)_SRC)/*) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(YF_AKCAREA_HOST_DIR)
	mkdir -p $(YF_AKCAREA_HOST_DIR)
	$(call COPY_USING_TAR,$(YF_AKCAREA_HOST_SRC),$(YF_AKCAREA_HOST_DIR))
	touch $@

$($(TOOL)_BUILD_DIR): $($(TOOL)_DIR)/.unpacked $(DTC_HOST_LIBFDT_DIR)/libfdt.a | $($(TOOL)_DEPENDS)
	$(TOOL_SUBMAKE) -C $(YF_AKCAREA_HOST_DIR) \
		OPT="-O0" \
		CC="$(TOOLS_CC)" \
		BITNESS="$(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LIBFDT_DIR=$(DTC_HOST_LIBFDT_DIR) \
		$(YF_AKCAREA_HOST_BINS:%=avm_kernel_config.%)
	touch -c $@

$($(TOOL)_TARGET_DIR): $(TOOLS_DIR)/avm_kernel_config.%: $($(TOOL)_DIR)/avm_kernel_config.%
	$(INSTALL_FILE)

$(tool)-precompiled: $($(TOOL)_TARGET_DIR)


$(tool)-clean:
	-$(MAKE) -C $(YF_AKCAREA_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(YF_AKCAREA_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(YF_AKCAREA_HOST_TARGET_DIR)

$(TOOL_FINISH)
