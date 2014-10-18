ifeq ($(strip $(FREETZ_STRIP_LIBRARIES)),y)
TOOLS+=mklibs
endif

MKLIBS_VERSION:=0.1.34
MKLIBS_SOURCE:=mklibs_$(MKLIBS_VERSION).tar.gz
MKLIBS_SOURCE_MD5:=afe0ed527ba96b8a882b5de350603007
MKLIBS_SITE:=http://ftp.de.debian.org/debian/pool/main/m/mklibs
MKLIBS_DIR:=$(TOOLS_SOURCE_DIR)/mklibs-$(MKLIBS_VERSION)
MKLIBS_MAKE_DIR:=$(TOOLS_DIR)/make/mklibs
MKLIBS_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build/bin
MKLIBS_SCRIPT:=$(MKLIBS_DIR)/src/mklibs
MKLIBS_TARGET_SCRIPT:=$(MKLIBS_DESTDIR)/mklibs
MKLIBS_READELF_BINARY:=$(MKLIBS_DIR)/src/mklibs-readelf/mklibs-readelf
MKLIBS_READELF_TARGET_BINARY:=$(MKLIBS_DESTDIR)/mklibs-readelf

mklibs-source: $(DL_DIR)/$(MKLIBS_SOURCE)
$(DL_DIR)/$(MKLIBS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(MKLIBS_SOURCE) $(MKLIBS_SITE) $(MKLIBS_SOURCE_MD5)

mklibs-unpacked: $(MKLIBS_DIR)/.unpacked
$(MKLIBS_DIR)/.unpacked: $(DL_DIR)/$(MKLIBS_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(MKLIBS_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(MKLIBS_MAKE_DIR)/patches,$(MKLIBS_DIR))
	touch $@

$(MKLIBS_SCRIPT): $(MKLIBS_DIR)/.unpacked

$(MKLIBS_DIR)/.configured: $(MKLIBS_DIR)/.unpacked
	(cd $(MKLIBS_DIR); rm -rf config.cache; \
		./configure \
		--prefix=/ \
		$(DISABLE_NLS) \
	);
	touch $@

$(MKLIBS_READELF_BINARY): $(MKLIBS_DIR)/.configured
	$(MAKE) -C $(MKLIBS_DIR) all

$(MKLIBS_TARGET_SCRIPT): $(MKLIBS_SCRIPT)
	$(INSTALL_FILE)

$(MKLIBS_READELF_TARGET_BINARY): $(MKLIBS_READELF_BINARY)
	$(INSTALL_FILE)

mklibs: $(MKLIBS_TARGET_SCRIPT) $(MKLIBS_READELF_TARGET_BINARY)

mklibs-clean:
	$(MAKE) -C $(MKLIBS_DIR) clean

mklibs-dirclean:
	$(RM) -r $(MKLIBS_DIR)

mklibs-distclean: mklibs-dirclean
	$(RM) -r $(MKLIBS_TARGET_SCRIPT) $(MKLIBS_READELF_TARGET_BINARY)
