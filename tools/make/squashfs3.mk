SQUASHFS3_VERSION:=3.4
SQUASHFS3_SOURCE:=squashfs$(SQUASHFS3_VERSION).tar.gz
SQUASHFS3_SOURCE_MD5:=2a4d2995ad5aa6840c95a95ffa6b1da6
SQUASHFS3_SITE:=@SF/squashfs
SQUASHFS3_DIR:=$(SOURCE_DIR)/squashfs$(SQUASHFS3_VERSION)

MKSQUASHFS3_DIR:=$(SQUASHFS3_DIR)/squashfs-tools
MKSQUASHFS3_MAKE_DIR:=$(TOOLS_DIR)/make

UNSQUASHFS3_DIR:=$(SQUASHFS3_DIR)/squashfs-tools
UNSQUASHFS3_MAKE_DIR:=$(TOOLS_DIR)/make

SQUASHFS3_LZMA_VERSION:=443
SQUASHFS3_LZMA_DIR:=$(SOURCE_DIR)/lzma$(SQUASHFS3_LZMA_VERSION)
SQUASHFS3_EXTERNAL_LZMA_DIR:=../../lzma$(SQUASHFS3_LZMA_VERSION)


$(DL_DIR)/$(SQUASHFS3_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TOOLS_DOT_CONFIG) $(SQUASHFS3_SOURCE) $(SQUASHFS3_SITE) $(SQUASHFS3_SOURCE_MD5)


$(SQUASHFS3_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS3_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(SQUASHFS3_SOURCE)
	for i in $(MKSQUASHFS3_MAKE_DIR)/patches/*.squashfs3.patch; do \
		$(PATCH_TOOL) $(SQUASHFS3_DIR) $$i; \
	done
	touch $@

$(MKSQUASHFS3_DIR)/mksquashfs3-lzma: $(SQUASHFS3_DIR)/.unpacked
	$(MAKE) CXX="$(TOOLS_CXX)" LZMA_DIR="$(SQUASHFS3_EXTERNAL_LZMA_DIR)" \
		-C $(MKSQUASHFS3_DIR) mksquashfs3-lzma
	touch -c $@

$(UNSQUASHFS3_DIR)/unsquashfs3-lzma: $(SQUASHFS3_DIR)/.unpacked
	$(MAKE) CXX="$(TOOLS_CXX)" LZMA_DIR="$(SQUASHFS3_EXTERNAL_LZMA_DIR)" \
		-C $(MKSQUASHFS3_DIR) unsquashfs3-lzma
	touch -c $@

$(TOOLS_DIR)/mksquashfs3-lzma: $(MKSQUASHFS3_DIR)/mksquashfs3-lzma
	cp $(MKSQUASHFS3_DIR)/mksquashfs3-lzma $(TOOLS_DIR)/mksquashfs3-lzma

$(TOOLS_DIR)/unsquashfs3-lzma: $(UNSQUASHFS3_DIR)/unsquashfs3-lzma
	cp $(UNSQUASHFS3_DIR)/unsquashfs3-lzma $(TOOLS_DIR)/unsquashfs3-lzma

squashfs3: $(TOOLS_DIR)/mksquashfs3-lzma $(TOOLS_DIR)/unsquashfs3-lzma

squashfs3-source: $(SQUASHFS3_DIR)/.unpacked

squashfs3-clean:
	-$(MAKE) -C $(MKSQUASHFS3_DIR) clean

squashfs3-dirclean:
	$(RM) -r $(SQUASHFS3_DIR)

squashfs3-distclean: squashfs3-dirclean
	$(RM) $(TOOLS_DIR)/mksquashfs3-lzma
	$(RM) $(TOOLS_DIR)/unsquashfs3-lzma
