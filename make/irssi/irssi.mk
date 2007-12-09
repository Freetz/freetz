$(call PKG_INIT_BIN, 0.8.12)
$(PKG)_SOURCE:=irssi-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://irssi.org/files
$(PKG)_BINARY:=$($(PKG)_DIR)/src/fe-text/irssi
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/irssi

$(PKG)_DEPENDS_ON += glib2 ncurses

ifeq ($(strip $(DS_PACKAGE_IRSSI_WITH_OPENSSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif

$(PKG_SOURCE_DOWNLOAD)

$(PKG)_DS_CONFIG_FILE:=$($(PKG)_MAKE_DIR)/.ds_config
$(PKG)_DS_CONFIG_TEMP:=$($(PKG)_MAKE_DIR)/.ds_config.temp

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS:=\
	--with-textui \
	--with-perl=no \
	--disable-ipv6 \
	$(if $(DS_PACKAGE_IRSSI_WITH_BOT),--with-bot,) \
	$(if $(DS_PACKAGE_IRSSI_WITH_PROXY),--with-proxy,) \
	$(if $(DS_PACKAGE_IRSSI_WITH_OPENSSL),,--disable-ssl) \

$(IRSSI_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_PACKAGE_IRSSI_WITH_BOT=$(if $(DS_PACKAGE_IRSSI_WITH_BOT),y,n)" > $(IRSSI_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_IRSSI_WITH_PROXY=$(if $(DS_PACKAGE_IRSSI_WITH_PROXY),y,n)" > $(IRSSI_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_IRSSI_WITH_OPENSSL=$(if $(DS_PACKAGE_IRSSI_WITH_OPENSSL),y,n)" > $(IRSSI_DS_CONFIG_TEMP)
	@diff -q $(IRSSI_DS_CONFIG_TEMP) $(IRSSI_DS_CONFIG_FILE) || \
		cp $(IRSSI_DS_CONFIG_TEMP) $(IRSSI_DS_CONFIG_FILE)
	@rm -f $(IRSSI_DS_CONFIG_TEMP)

$(IRSSI_DIR)/.unpacked: $(DL_DIR)/$(IRSSI_SOURCE) $(IRSSI_DS_CONFIG_FILE)
	rm -rf $(IRSSI_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(IRSSI_SOURCE)
	touch $@

$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C $(IRSSI_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LD="$(TARGET_CC)" \

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): $($(PKG)_BINARY)

$(pkg)-precompiled: $(pkg) $($(PKG)_TARGET_BINARY) 

$(pkg)-clean:
	-$(MAKE) -C $(IRSSI_DIR) clean

$(pkg)-uninstall: 
	rm -f $(IRSSI_TARGET_BINARY)

$(PKG_FINISH)
