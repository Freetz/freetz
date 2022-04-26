$(call TOOL_INIT, 2.2-r2)
$(TOOL)_SOURCE:=squashfs$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_MD5:=a8d09a217240127ae4d339e8368d2de1
$(TOOL)_SITE:=@SF/squashfs

$(TOOL)_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$($(TOOL)_VERSION)
$(TOOL)_BUILD_DIR:=$($(TOOL)_DIR)/squashfs-tools

$(TOOL)_TOOLS:=mksquashfs
$(TOOL)_TOOLS_BUILD_DIR:=$($(TOOL)_TOOLS:%=$($(TOOL)_BUILD_DIR)/%-lzma)
$(TOOL)_TOOLS_TARGET_DIR:=$($(TOOL)_TOOLS:%=$(TOOLS_DIR)/%2-lzma)


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SQUASHFS2_HOST_SOURCE) $(SQUASHFS2_HOST_SITE) $(SQUASHFS2_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SQUASHFS2_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SQUASHFS2_HOST_MAKE_DIR)/patches,$(SQUASHFS2_HOST_DIR))
	touch $@

$($(TOOL)_TOOLS_BUILD_DIR): $($(TOOL)_DIR)/.unpacked $(LZMA1_HOST_DIR)/liblzma1.a
	$(TOOL_SUBMAKE) -C $(SQUASHFS2_HOST_BUILD_DIR) \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) -fcommon" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		\
		LZMA_LIBNAME=lzma1 \
		LZMA_DIR="$(abspath $(LZMA1_HOST_DIR))" \
		$(SQUASHFS2_HOST_TOOLS:%=%-lzma)
	touch -c $@

$($(TOOL)_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%2-lzma: $($(TOOL)_BUILD_DIR)/%-lzma
	$(INSTALL_FILE)

$(tool)-precompiled: $($(TOOL)_TOOLS_TARGET_DIR)


$(tool)-clean:
	-$(MAKE) -C $(SQUASHFS2_HOST_BUILD_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(SQUASHFS2_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(SQUASHFS2_HOST_TOOLS_TARGET_DIR)

$(TOOL_FINISH)
