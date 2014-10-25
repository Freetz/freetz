TAR_HOST_VERSION:=1.28
TAR_HOST_SOURCE:=tar-$(TAR_HOST_VERSION).tar.bz2
TAR_HOST_SOURCE_MD5:=8f32b2bc1ed7ddf4cf4e4a39711341b0
TAR_HOST_SITE:=@GNU/tar

TAR_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/tar-host
TAR_HOST_DIR:=$(TOOLS_SOURCE_DIR)/tar-$(TAR_HOST_VERSION)

tar-host-source: $(DL_DIR)/$(TAR_HOST_SOURCE)
$(DL_DIR)/$(TAR_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TAR_HOST_SOURCE) $(TAR_HOST_SITE) $(TAR_HOST_SOURCE_MD5)

tar-host-unpacked: $(TAR_HOST_DIR)/.unpacked
$(TAR_HOST_DIR)/.unpacked: $(DL_DIR)/$(TAR_HOST_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(TAR_HOST_SOURCE)
	$(call APPLY_PATCHES,$(TAR_HOST_MAKE_DIR)/patches,$(TAR_HOST_DIR))
	touch $@

$(TAR_HOST_DIR)/.configured: $(TAR_HOST_DIR)/.unpacked
	(cd $(TAR_HOST_DIR); rm -rf config.cache; \
		CFLAGS="-Wall -O2" \
		CC="$(TOOLS_CC)" \
		./configure \
		--prefix=/usr \
		--without-selinux \
		$(DISABLE_NLS) \
	);
	touch $@

$(TAR_HOST_DIR)/src/tar: $(TAR_HOST_DIR)/.configured
	$(MAKE) -C $(TAR_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/tar-gnu: $(TAR_HOST_DIR)/src/tar
	$(INSTALL_FILE)
	strip $@

tar-host: $(TOOLS_DIR)/tar-gnu

tar-host-clean:
	-$(MAKE) -C $(TAR_HOST_DIR) clean

tar-host-dirclean:
	$(RM) -r $(TAR_HOST_DIR)

tar-host-distclean: tar-host-dirclean
	$(RM) $(TOOLS_DIR)/tar-gnu
