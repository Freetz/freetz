$(call PKG_INIT_BIN, 2.8.7)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=493af4c77ef6761e3f0157cd1be033a0
$(PKG)_SITE:=http://lynx.isc.org/lynx$($(PKG)_VERSION)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)2-8-7

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_CFG:=$($(PKG)_DIR)/$(pkg).cfg
$(PKG)_TARGET_CFG:=$($(PKG)_DEST_DIR)/etc/$(pkg).cfg
$(PKG)_LSS:=$($(PKG)_DIR)/samples/$(pkg).lss
$(PKG)_TARGET_LSS:=$($(PKG)_DEST_DIR)/etc/$(pkg).lss

$(PKG)_CONFIGURE_OPTIONS += \
	--enable-warnings \
	--with-screen=ncurses \
	--enable-nested-tables \
	--enable-read-eta \
	--enable-charset-choice \
	--disable-alt-bindings \
	--disable-bibp-urls \
	--disable-config-info \
	--disable-dired \
	--disable-finger \
	--disable-gopher \
	--disable-news \
	--disable-nls \
	--disable-prettysrc \
	--disable-source-cache \
	--disable-trace

$(PKG)_DEPENDS_ON := ncurses

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_CFG) $($(PKG)_LSS): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LYNX_DIR) \
		LD="$(TARGET_LD)"
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_CFG): $($(PKG)_CFG)
	$(INSTALL_FILE)

$($(PKG)_TARGET_LSS): $($(PKG)_LSS)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_CFG) $($(PKG)_TARGET_LSS)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LYNX_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LYNX_TARGET_BINARY) $(LYNX_TARGET_CFG) $(LYNX_TARGET_LSS)

$(PKG_FINISH)
