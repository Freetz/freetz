LZMA2_VERSION:=5.2.1
LZMA2_SOURCE:=xz-$(LZMA2_VERSION).tar.xz
LZMA2_SOURCE_MD5_5.0.8:=edddf73ed88d83c31914737ddd3d2bfa
LZMA2_SOURCE_MD5_5.2.1:=b5e2dd95dc8498cea5354377ed89aa65
LZMA2_SOURCE_MD5:=$(LZMA2_SOURCE_MD5_$(LZMA2_VERSION))
LZMA2_SITE:=http://tukaani.org/xz

LZMA2_DIR:=$(TOOLS_SOURCE_DIR)/xz-$(LZMA2_VERSION)
LZMA2_MAKE_DIR:=$(TOOLS_DIR)/make/lzma2

LZMA2_ALONE_DIR:=$(LZMA2_DIR)/src/xz
LZMA2_LIB_DIR:=$(LZMA2_DIR)/src/liblzma/.libs

lzma2-source: $(DL_DIR)/$(LZMA2_SOURCE)
$(DL_DIR)/$(LZMA2_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LZMA2_SOURCE) $(LZMA2_SITE) $(LZMA2_SOURCE_MD5)

lzma2-unpacked: $(LZMA2_DIR)/.unpacked
$(LZMA2_DIR)/.unpacked: $(DL_DIR)/$(LZMA2_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	mkdir -p $(LZMA2_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LZMA2_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(LZMA2_MAKE_DIR)/patches/$(LZMA2_VERSION),$(LZMA2_DIR))
	touch $@

$(LZMA2_DIR)/.configured: $(LZMA2_DIR)/.unpacked
	(cd $(LZMA2_DIR); ./configure \
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
	);
	touch $@

$(LZMA2_LIB_DIR)/liblzma.a $(LZMA2_ALONE_DIR)/xz: $(LZMA2_DIR)/.configured
	$(MAKE) -C $(LZMA2_DIR)

$(LZMA2_DIR)/liblzma.a: $(LZMA2_LIB_DIR)/liblzma.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/xz: $(LZMA2_ALONE_DIR)/xz
	$(INSTALL_FILE)

lzma2: $(LZMA2_DIR)/liblzma.a $(TOOLS_DIR)/xz

lzma2-clean:
	-$(MAKE) -C $(LZMA2_DIR) clean
	$(RM) $(LZMA2_DIR)/liblzma.a

lzma2-dirclean:
	$(RM) -r $(LZMA2_DIR)

lzma2-distclean: lzma2-dirclean
	$(RM) $(TOOLS_DIR)/xz
