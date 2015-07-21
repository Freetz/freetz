LZMA_HOST_VERSION:=465
LZMA_HOST_SOURCE:=lzma$(LZMA_HOST_VERSION).tar.bz2
LZMA_HOST_SOURCE_MD5:=29d5ffd03a5a3e51aef6a74e9eafb759
LZMA_HOST_SITE:=@SF/sevenzip

LZMA_HOST_DIR:=$(TOOLS_SOURCE_DIR)/lzma$(LZMA_HOST_VERSION)
LZMA_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/lzma-host

LZMA_HOST_ALONE_DIR:=$(LZMA_HOST_DIR)/CPP/7zip/Compress/LZMA_Alone
LZMA_HOST_LIB_DIR:=$(LZMA_HOST_DIR)/CPP/7zip/Compress/LZMA_Lib

lzma-host-source: $(DL_DIR)/$(LZMA_HOST_SOURCE)
$(DL_DIR)/$(LZMA_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LZMA_HOST_SOURCE) $(LZMA_HOST_SITE) $(LZMA_HOST_SOURCE_MD5)

lzma-host-unpacked: $(LZMA_HOST_DIR)/.unpacked
$(LZMA_HOST_DIR)/.unpacked: $(DL_DIR)/$(LZMA_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	mkdir -p $(LZMA_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LZMA_HOST_SOURCE),$(LZMA_HOST_DIR))
	$(call APPLY_PATCHES,$(LZMA_HOST_MAKE_DIR)/patches,$(LZMA_HOST_DIR))
	touch $@

$(LZMA_HOST_ALONE_DIR)/lzma: $(LZMA_HOST_DIR)/.unpacked
	$(MAKE) -f makefile.gcc -C $(LZMA_HOST_ALONE_DIR)

$(LZMA_HOST_LIB_DIR)/liblzma.a: $(LZMA_HOST_DIR)/.unpacked
	$(MAKE) -f makefile.gcc -C $(LZMA_HOST_LIB_DIR)
	touch -c $@

$(LZMA_HOST_DIR)/liblzma.a: $(LZMA_HOST_LIB_DIR)/liblzma.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/lzma: $(LZMA_HOST_ALONE_DIR)/lzma
	$(INSTALL_FILE)

lzma-host: $(LZMA_HOST_DIR)/liblzma.a $(TOOLS_DIR)/lzma

lzma-host-clean:
	-$(MAKE) -C $(LZMA_HOST_LIB_DIR) clean
	$(RM) $(LZMA_HOST_DIR)/liblzma.a

lzma-host-dirclean:
	$(RM) -r $(LZMA_HOST_DIR)

lzma-host-distclean: lzma-host-dirclean
	$(RM) $(TOOLS_DIR)/lzma
