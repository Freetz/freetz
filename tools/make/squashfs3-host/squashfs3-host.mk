$(call TOOL_INIT, 3.4)
$(TOOL)_SOURCE:=squashfs$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_MD5:=2a4d2995ad5aa6840c95a95ffa6b1da6
$(TOOL)_SITE:=@SF/squashfs

$(TOOL)_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$($(TOOL)_VERSION)
$(TOOL)_BUILD_DIR:=$($(TOOL)_DIR)/squashfs-tools

$(TOOL)_TOOLS:=mksquashfs unsquashfs
$(TOOL)_TOOLS_BUILD_DIR:=$($(TOOL)_TOOLS:%=$($(TOOL)_BUILD_DIR)/%-multi)
$(TOOL)_TOOLS_TARGET_DIR:=$($(TOOL)_TOOLS:%=$(TOOLS_DIR)/%3-multi)


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SQUASHFS3_HOST_SOURCE) $(SQUASHFS3_HOST_SITE) $(SQUASHFS3_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SQUASHFS3_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SQUASHFS3_HOST_MAKE_DIR)/patches,$(SQUASHFS3_HOST_DIR))
	touch $@

$($(TOOL)_TOOLS_BUILD_DIR): $($(TOOL)_DIR)/.unpacked $(LZMA1_HOST_DIR)/liblzma1.a
	$(TOOL_SUBMAKE) -C $(SQUASHFS3_HOST_BUILD_DIR) \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) -fcommon" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		LZMA1_SUPPORT=1 \
		LZMA_LIBNAME=lzma1 \
		LZMA_DIR="$(abspath $(LZMA1_HOST_DIR))" \
		$(SQUASHFS3_HOST_TOOLS:%=%-multi)
	touch -c $@

$($(TOOL)_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%3-multi: $($(TOOL)_BUILD_DIR)/%-multi
	$(INSTALL_FILE)

$(tool)-precompiled: $($(TOOL)_TOOLS_TARGET_DIR)


$(tool)-clean:
	-$(MAKE) -C $(SQUASHFS3_HOST_BUILD_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(SQUASHFS3_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(SQUASHFS3_HOST_TOOLS_TARGET_DIR)

$(TOOL_FINISH)
