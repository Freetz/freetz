SFK_HOST_VERSION:=1.9.1
SFK_HOST_SOURCE:=sfk-$(SFK_HOST_VERSION).tar.gz
SFK_HOST_SOURCE_MD5:=c2d542df23e2da37ac1be79932e685ed
SFK_HOST_SITE:=@SF/swissfileknife

SFK_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/sfk-host
SFK_HOST_DIR:=$(TOOLS_SOURCE_DIR)/sfk-$(SFK_HOST_VERSION)
SFK_HOST_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)

sfk-host-source: $(DL_DIR)/$(SFK_HOST_SOURCE)
$(DL_DIR)/$(SFK_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SFK_HOST_SOURCE) $(SFK_HOST_SITE) $(SFK_HOST_SOURCE_MD5)

sfk-host-unpacked: $(SFK_HOST_DIR)/.unpacked
$(SFK_HOST_DIR)/.unpacked: $(DL_DIR)/$(SFK_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SFK_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SFK_HOST_MAKE_DIR)/patches,$(SFK_HOST_DIR))
	touch $@

$(SFK_HOST_DIR)/.configured: $(SFK_HOST_DIR)/.unpacked
	(cd $(SFK_HOST_DIR); $(RM) config.cache; \
		./configure \
		--prefix=$(SFK_HOST_DESTDIR) \
		$(DISABLE_NLS) \
	);
	touch $@

$(SFK_HOST_DIR)/sfk: $(SFK_HOST_DIR)/.configured
	$(MAKE) -C $(SFK_HOST_DIR) all

$(TOOLS_DIR)/sfk: $(SFK_HOST_DIR)/sfk
	$(INSTALL_FILE)
	strip $@

sfk-host: $(TOOLS_DIR)/sfk

sfk-host-clean:
	-$(MAKE) -C $(SFK_HOST_DIR) clean

sfk-host-dirclean:
	$(RM) -r $(SFK_HOST_DIR)

sfk-host-distclean: sfk-host-dirclean
	$(RM) $(TOOLS_DIR)/sfk
