$(call TOOLS_INIT, 2.2-r2)
$(PKG)_SOURCE:=squashfs$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=750a7a4896d782698a0f531ca30582f0ddd365fe317a04c4dd4fa1ce2eb053eb
$(PKG)_SITE:=@SF/squashfs

$(PKG)_BUILD_DIR:=$($(PKG)_DIR)/squashfs-tools

$(PKG)_TOOLS:=mksquashfs
$(PKG)_TOOLS_BUILD_DIR:=$($(PKG)_TOOLS:%=$($(PKG)_BUILD_DIR)/%-lzma)
$(PKG)_TOOLS_TARGET_DIR:=$($(PKG)_TOOLS:%=$(TOOLS_DIR)/%2-lzma)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_TOOLS_BUILD_DIR): $($(PKG)_DIR)/.unpacked $(LZMA1_HOST_DIR)/liblzma1.a
	$(TOOLS_SUBMAKE) -C $(SQUASHFS2_HOST_BUILD_DIR) \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) -fcommon" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		\
		LZMA_LIBNAME=lzma1 \
		LZMA_DIR="$(abspath $(LZMA1_HOST_DIR))" \
		$(SQUASHFS2_HOST_TOOLS:%=%-lzma)
	touch -c $@

$($(PKG)_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%2-lzma: $($(PKG)_BUILD_DIR)/%-lzma
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TOOLS_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(SQUASHFS2_HOST_BUILD_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(SQUASHFS2_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(SQUASHFS2_HOST_TOOLS_TARGET_DIR)

$(TOOLS_FINISH)
