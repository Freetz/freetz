LZMA2_HOST_VERSION:=5.2.5
LZMA2_HOST_SOURCE:=xz-$(LZMA2_HOST_VERSION).tar.xz
LZMA2_HOST_SOURCE_MD5:=aa1621ec7013a19abab52a8aff04fe5b
LZMA2_HOST_SITE:=http://tukaani.org/xz

LZMA2_HOST_DIR:=$(TOOLS_SOURCE_DIR)/xz-$(LZMA2_HOST_VERSION)
LZMA2_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/lzma2-host

LZMA2_HOST_ALONE_DIR:=$(LZMA2_HOST_DIR)/src/xz
LZMA2_HOST_LIB_DIR:=$(LZMA2_HOST_DIR)/src/liblzma/.libs


lzma2-host-source: $(DL_DIR)/$(LZMA2_HOST_SOURCE)
$(DL_DIR)/$(LZMA2_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LZMA2_HOST_SOURCE) $(LZMA2_HOST_SITE) $(LZMA2_HOST_SOURCE_MD5)

lzma2-host-unpacked: $(LZMA2_HOST_DIR)/.unpacked
$(LZMA2_HOST_DIR)/.unpacked: $(DL_DIR)/$(LZMA2_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	mkdir -p $(LZMA2_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LZMA2_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(LZMA2_HOST_MAKE_DIR)/patches/$(LZMA2_HOST_VERSION),$(LZMA2_HOST_DIR))
	touch $@

$(LZMA2_HOST_DIR)/.configured: $(LZMA2_HOST_DIR)/.unpacked
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

$(LZMA2_HOST_LIB_DIR)/liblzma.a $(LZMA2_HOST_ALONE_DIR)/xz: $(LZMA2_HOST_DIR)/.configured
	$(MAKE) -C $(LZMA2_HOST_DIR) $(SILENT)

$(LZMA2_HOST_DIR)/liblzma.a: $(LZMA2_HOST_LIB_DIR)/liblzma.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/xz: $(LZMA2_HOST_ALONE_DIR)/xz
	$(INSTALL_FILE)

lzma2-host-precompiled: $(LZMA2_HOST_DIR)/liblzma.a $(TOOLS_DIR)/xz


lzma2-host-clean:
	-$(MAKE) -C $(LZMA2_HOST_DIR) clean
	$(RM) $(LZMA2_HOST_DIR)/liblzma.a

lzma2-host-dirclean:
	$(RM) -r $(LZMA2_HOST_DIR)

lzma2-host-distclean: lzma2-host-dirclean
	$(RM) $(TOOLS_DIR)/xz

