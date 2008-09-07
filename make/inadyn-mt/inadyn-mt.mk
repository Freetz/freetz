$(call PKG_INIT_BIN,02.12.24)
$(PKG)_SOURCE:=$(pkg).v.$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://switch.dl.sourceforge.net/sourceforge/inadyn-mt
$(PKG)_BINARY:=$($(PKG)_DIR)/bin/linux/inadyn-mt
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/inadyn-mt

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(INADYN_DIR) \
		CC="mipsel-linux-gcc" \
		STRIP="mipsel-linux-strip" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(INADYN_DIR) clean

$(pkg)-uninstall:
	$(RM) $(INADYN_TARGET_BINARY)

$(PKG_FINISH)
