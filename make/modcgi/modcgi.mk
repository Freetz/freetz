MODCGI_VERSION:=0.2
MODCGI_SOURCE:=modcgi-$(MODCGI_VERSION).tar.bz2
MODCGI_SITE:=http://www.eiband.info/dsmod/source
MODCGI_DIR:=$(SOURCE_DIR)/modcgi-$(MODCGI_VERSION)
MODCGI_BINARY:=$(MODCGI_DIR)/modcgi
MODCGI_TARGET_DIR:=root/usr/bin
MODCGI_TARGET_BINARY:=$(MODCGI_TARGET_DIR)/modcgi


$(DL_DIR)/$(MODCGI_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(MODCGI_SOURCE) $(MODCGI_SITE)

$(MODCGI_DIR)/.unpacked: $(DL_DIR)/$(MODCGI_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(MODCGI_SOURCE)
	touch $@

$(MODCGI_BINARY): $(MODCGI_DIR)/.unpacked
	$(MAKE) CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		-C $(MODCGI_DIR)
		
$(MODCGI_TARGET_BINARY): $(MODCGI_BINARY)
	$(INSTALL_BINARY_STRIP)
	
modcgi-precompiled: uclibc $(MODCGI_TARGET_BINARY)

modcgi-source: $(MODCGI_DIR)/.unpacked

modcgi-clean:
	-$(MAKE) -C $(MODCGI_DIR) clean

modcgi-dirclean:
	rm -rf $(MODCGI_DIR)

modcgi-uninstall:
	rm -f $(MODCGI_TARGET_BINARY)