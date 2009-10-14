$(call PKG_INIT_BIN, 1.0.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.pps.jussieu.fr/~jch/software/files/polipo/
$(PKG)_BINARY:=$($(PKG)_DIR)/polipo
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/polipo
$(PKG)_SOURCE_MD5:=defdce7f8002ca68705b6c2c36c4d096 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(POLIPO_DIR) \
		CC="$(TARGET_CC)" \
		CDEBUGFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(POLIPO_DIR) clean

$(pkg)-uninstall:
	$(RM) $(POLIPO_TARGET_BINARY)

$(PKG_FINISH)
