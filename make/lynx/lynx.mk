$(call PKG_INIT_BIN, 2.8.9rel.1)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=387f193d7792f9cfada14c60b0e5c0bff18f227d9257a39483e14fa1aaf79595
$(PKG)_SITE:=https://invisible-mirror.net/archives/lynx/tarballs,ftp://ftp.invisible-island.net/lynx/tarballs
### WEBSITE:=https://lynx.invisible-island.net/
### MANPAGE:=https://lynx.invisible-island.net/lynx_help/lynx_help_main.html
### CHANGES:=https://lynx.invisible-island.net/current/CHANGES.html

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_CFG:=$($(PKG)_DIR)/$(pkg).cfg
$(PKG)_TARGET_CFG:=$($(PKG)_DEST_DIR)/etc/$(pkg).cfg
$(PKG)_LSS:=$($(PKG)_DIR)/samples/$(pkg).lss
$(PKG)_TARGET_LSS:=$($(PKG)_DEST_DIR)/etc/$(pkg).lss

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LYNX_WITH_SSL $(if $(FREETZ_PACKAGE_LYNX_WITH_SSL),FREETZ_OPENSSL_SHLIB_VERSION)
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LYNX_WITH_ZLIB

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

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_LYNX_WITH_SSL),--with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_LYNX_WITH_ZLIB),--with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-zlib)

$(PKG)_DEPENDS_ON += ncurses
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_LYNX_WITH_SSL),openssl)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_LYNX_WITH_ZLIB),zlib)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LYNX_DIR) \
		LD="$(TARGET_LD)"
	@touch $@

$($(PKG)_CFG) $($(PKG)_LSS): $($(PKG)_DIR)/.unpacked
	@touch $@

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
