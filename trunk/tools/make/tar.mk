TAR_VERSION:=1.15.1
TAR_SOURCE:=tar-$(TAR_VERSION).tar.bz2
TAR_SITE:=http://ftp.gnu.org/gnu/tar
TAR_DIR:=$(SOURCE_DIR)/tar-$(TAR_VERSION)

$(DL_DIR)/$(TAR_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(TAR_SITE)/$(TAR_SOURCE)

$(TAR_DIR)/.unpacked: $(DL_DIR)/$(TAR_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(TAR_SOURCE)
	touch $@

$(TAR_DIR)/.configured: $(TAR_DIR)/.unpacked
	(cd $(TAR_DIR); rm -rf config.cache; \
		CFLAGS="-O2 -Wall" \
		CC="$(TOOLS_CC)" \
		./configure \
		--prefix=/usr \
		$(DISABLE_NLS) \
	);
	touch $@

$(TAR_DIR)/src/tar: $(TAR_DIR)/.configured
	$(MAKE) CC="$(TOOLS_CC)" \
		-C $(TAR_DIR) all
	touch -c $@

$(TOOLS_DIR)/tar: $(TAR_DIR)/src/tar
	cp $(TAR_DIR)/src/tar $(TOOLS_DIR)/tar
	strip $(TOOLS_DIR)/tar

tar: $(TOOLS_DIR)/tar

tar-source: $(TAR_DIR)/.unpacked

tar-clean:
	-$(MAKE) -C $(TAR_DIR) clean

tar-dirclean:
	rm -rf $(TAR_DIR)

tar-distclean: tar-dirclean
	rm -f $(TOOLS_DIR)/tar
