$(call PKG_INIT_BIN, 0.2.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ab5cc15b4b1d827443f7950cd935bc6a
$(PKG)_SITE:=http://$(pkg).googlecode.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_DEPENDS_ON := polarssl libconfig

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UMURMUR_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DUSE_POLARSSL" \
		EXTRA_LDFLAGS="-lpolarssl" \
		AR="$(TARGET_CROSS)ar"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UMURMUR_DIR)/src clean
	$(RM) $(UMURMUR_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UMURMUR_TARGET_BINARY)

$(PKG_FINISH)
