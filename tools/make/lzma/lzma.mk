LZMA_VERSION:=443
LZMA_SOURCE:=lzma$(LZMA_VERSION).tar.bz2
LZMA_SOURCE_MD5:=c4e1b467184c7cffd4371c74df2baf0f
LZMA_SITE:=@SF/sevenzip
LZMA_DIR:=$(TOOLS_SOURCE_DIR)/lzma$(LZMA_VERSION)
LZMA_MAKE_DIR:=$(TOOLS_DIR)/make/lzma
LZMA_ALONE_DIR:=$(LZMA_DIR)/C/7zip/Compress/LZMA_Alone
LZMA_LIB_DIR:=$(LZMA_DIR)/C/7zip/Compress/LZMA_Lib

lzma-source: $(DL_DIR)/$(LZMA_SOURCE)
$(DL_DIR)/$(LZMA_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LZMA_SOURCE) $(LZMA_SITE) $(LZMA_SOURCE_MD5)

lzma-unpacked: $(LZMA_DIR)/.unpacked
$(LZMA_DIR)/.unpacked: $(DL_DIR)/$(LZMA_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	mkdir -p $(LZMA_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LZMA_SOURCE),$(LZMA_DIR))
	$(call APPLY_PATCHES,$(LZMA_MAKE_DIR)/patches,$(LZMA_DIR))
	touch $@

$(LZMA_ALONE_DIR)/lzma: $(LZMA_DIR)/.unpacked
	$(MAKE) -f makefile.gcc -C $(LZMA_ALONE_DIR)

$(LZMA_LIB_DIR)/liblzma.a: $(LZMA_DIR)/.unpacked
	$(MAKE) -C $(LZMA_LIB_DIR)
	touch -c $@

$(LZMA_DIR)/liblzma.a: $(LZMA_LIB_DIR)/liblzma.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/lzma: $(LZMA_ALONE_DIR)/lzma
	$(INSTALL_FILE)

lzma: $(LZMA_DIR)/liblzma.a $(TOOLS_DIR)/lzma

lzma-clean:
	-$(MAKE) -C $(LZMA_LIB_DIR) clean
	$(RM) $(LZMA_DIR)/liblzma.a

lzma-dirclean:
	$(RM) -r $(LZMA_DIR)

lzma-distclean: lzma-dirclean
	$(RM) $(TOOLS_DIR)/lzma
