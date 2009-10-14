$(call PKG_INIT_BIN,4.27)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.stunnel.org/download/stunnel/src
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)
$(PKG)_STARTLEVEL=30
$(PKG)_SOURCE_MD5:=3c655d815576f50046a1c28744b88681 

$(PKG)_DEPENDS_ON := openssl zlib

$(PKG)_CONFIGURE_OPTIONS += --disable-libwrap
$(PKG)_CONFIGURE_OPTIONS += --with-threads=fork
#$(PKG)_CONFIGURE_OPTIONS += --with-threads=pthread
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(STUNNEL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(STUNNEL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STUNNEL_TARGET_BINARY)

$(PKG_FINISH)
