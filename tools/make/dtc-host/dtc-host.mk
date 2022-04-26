$(call TOOL_INIT, 1.6.1)
$(TOOL)_SOURCE:=dtc-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=65cec529893659a49a89740bb362f507a3b94fc8cd791e76a8d6a2b6f3203473
$(TOOL)_SITE:=@KERNEL/software/utils/dtc

$(TOOL)_LIBFDT_DIR:=$($(TOOL)_DIR)/libfdt


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(DTC_HOST_SOURCE) $(DTC_HOST_SITE) $(DTC_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(DTC_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(DTC_HOST_MAKE_DIR)/patches,$(DTC_HOST_DIR))
	touch $@

$($(TOOL)_LIBFDT_DIR)/libfdt.a: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) -f Makefile.freetz -C $(DTC_HOST_LIBFDT_DIR) all \
		CC="$(TOOLS_CC)" \
		BITNESS="$(HOST_CFLAGS_FORCE_32BIT_CODE)"
	touch -c $@

$(tool)-precompiled: $($(TOOL)_LIBFDT_DIR)/libfdt.a


$(tool)-clean:
	-$(MAKE) -f Makefile.freetz -C $(DTC_HOST_LIBFDT_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(DTC_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean

$(TOOL_FINISH)
