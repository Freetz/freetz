SFK_VERSION:=1.7.2
SFK_SOURCE:=sfk-$(SFK_VERSION).tar.gz
SFK_SOURCE_MD5:=1f924e8118b044ab61fdfd6dbc4fcd47
SFK_SITE:=@SF/swissfileknife

SFK_DIR:=$(TOOLS_SOURCE_DIR)/sfk-$(SFK_VERSION)
SFK_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)

sfk-source: $(DL_DIR)/$(SFK_SOURCE)
$(DL_DIR)/$(SFK_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SFK_SOURCE) $(SFK_SITE) $(SFK_SOURCE_MD5)

sfk-unpacked: $(SFK_DIR)/.unpacked
$(SFK_DIR)/.unpacked: $(DL_DIR)/$(SFK_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SFK_SOURCE),$(TOOLS_SOURCE_DIR))
	touch $@

$(SFK_DIR)/.configured: $(SFK_DIR)/.unpacked
	(cd $(SFK_DIR); $(RM) config.cache; \
		./configure \
		--prefix=$(SFK_DESTDIR) \
		$(DISABLE_NLS) \
	);
	touch $@

$(SFK_DIR)/sfk: $(SFK_DIR)/.configured
	$(MAKE) -C $(SFK_DIR) all

$(TOOLS_DIR)/sfk: $(SFK_DIR)/sfk
	$(INSTALL_FILE)
	strip $@

sfk: $(TOOLS_DIR)/sfk

sfk-clean:
	$(RM) $(SFK_DIR)/sfk

sfk-dirclean:
	$(RM) -r $(SFK_DIR)

sfk-distclean: sfk-dirclean
	$(RM) $(TOOLS_DIR)/sfk
