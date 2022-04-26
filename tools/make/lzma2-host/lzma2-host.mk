$(call TOOL_INIT, 5.2.5)
$(TOOL)_SOURCE:=xz-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_MD5:=aa1621ec7013a19abab52a8aff04fe5b
$(TOOL)_SITE:=http://tukaani.org/xz

$(TOOL)_DIR:=$(TOOLS_SOURCE_DIR)/xz-$($(TOOL)_VERSION)

$(TOOL)_ALONE_DIR:=$($(TOOL)_DIR)/src/xz
$(TOOL)_LIB_DIR:=$($(TOOL)_DIR)/src/liblzma/.libs


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LZMA2_HOST_SOURCE) $(LZMA2_HOST_SITE) $(LZMA2_HOST_SOURCE_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	mkdir -p $(LZMA2_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LZMA2_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(LZMA2_HOST_MAKE_DIR)/patches/$(LZMA2_HOST_VERSION),$(LZMA2_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(LZMA2_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--enable-encoders=lzma1,lzma2,delta \
		--enable-decoders=lzma1,lzma2,delta \
		--disable-lzmadec \
		--disable-lzmainfo \
		--disable-lzma-links \
		--disable-scripts \
		--disable-doc \
		--disable-nls \
		--disable-rpath \
		--enable-shared=no \
		--enable-static=yes \
		--without-libiconv-prefix \
		--without-libintl-prefix \
		$(SILENT) \
	);
	touch $@

$($(TOOL)_LIB_DIR)/liblzma.a $($(TOOL)_ALONE_DIR)/xz: $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(LZMA2_HOST_DIR)

$($(TOOL)_DIR)/liblzma.a: $($(TOOL)_LIB_DIR)/liblzma.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/xz: $($(TOOL)_ALONE_DIR)/xz
	$(INSTALL_FILE)

$(tool)-precompiled: $($(TOOL)_DIR)/liblzma.a $(TOOLS_DIR)/xz


$(tool)-clean:
	-$(MAKE) -C $(LZMA2_HOST_DIR) clean
	$(RM) $(LZMA2_HOST_DIR)/liblzma.a

$(tool)-dirclean:
	$(RM) -r $(LZMA2_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/xz

$(TOOL_FINISH)
