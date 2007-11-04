$(eval $(call PKG_INIT_BIN, 39))
$(PKG)_SOURCE:=deco$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/deco
$(PKG)_DIR:=$(SOURCE_DIR)/deco$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/deco
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/deco

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(DECO_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

deco:

deco-precompiled: uclibc deco $($(PKG)_TARGET_BINARY)

deco-clean:
	-$(MAKE) -C $(DECO_DIR) clean

deco-uninstall:
	rm -f $(DECO_TARGET_BINARY)

$(PKG_FINISH)
