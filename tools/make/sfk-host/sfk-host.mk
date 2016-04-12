SFKHOST_VERSION:=1.7.2
SFKHOST_SOURCE:=sfk-$(SFKHOST_VERSION).tar.gz
SFKHOST_SOURCE_MD5:=1f924e8118b044ab61fdfd6dbc4fcd47
SFKHOST_SITE:=@SF/swissfileknife

SFKHOST_DIR:=$(TOOLS_SOURCE_DIR)/sfk-$(SFKHOST_VERSION)
SFKHOST_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)

sfk-host-source: $(DL_DIR)/$(SFKHOST_SOURCE)
$(DL_DIR)/$(SFKHOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SFKHOST_SOURCE) $(SFKHOST_SITE) $(SFKHOST_SOURCE_MD5)

sfk-host-unpacked: $(SFKHOST_DIR)/.unpacked
$(SFKHOST_DIR)/.unpacked: $(DL_DIR)/$(SFKHOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SFKHOST_SOURCE),$(TOOLS_SOURCE_DIR))
	touch $@

$(SFKHOST_DIR)/.configured: $(SFKHOST_DIR)/.unpacked
	(cd $(SFKHOST_DIR); $(RM) config.cache; \
		./configure \
		--prefix=$(SFKHOST_DESTDIR) \
		$(DISABLE_NLS) \
	);
	touch $@

$(SFKHOST_DIR)/sfk: $(SFKHOST_DIR)/.configured
	$(MAKE) -C $(SFKHOST_DIR) all

$(TOOLS_DIR)/sfk: $(SFKHOST_DIR)/sfk
	$(INSTALL_FILE)
	strip $@

sfk-host: $(TOOLS_DIR)/sfk

sfk-host-clean:
	-$(MAKE) -C $(SFKHOST_DIR) clean

sfk-host-dirclean:
	$(RM) -r $(SFKHOST_DIR)

sfk-host-distclean: sfk-host-dirclean
	$(RM) $(TOOLS_DIR)/sfk
