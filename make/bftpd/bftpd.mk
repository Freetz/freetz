$(call PKG_INIT_BIN, 2.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/bftpd
$(PKG)_DIR:=$(SOURCE_DIR)/bftpd
$(PKG)_BINARY:=$($(PKG)_DIR)/bftpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/bftpd
$(PKG)_STARTLEVEL=40

ifeq ($(strip $(DS_PACKAGE_BFTPD_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON := zlib
endif

$(PKG)_CONFIG_SUBOPTS += DS_PACKAGE_BFTPD_WITH_ZLIB

$(PKG)_CONFIGURE_OPTIONS += $(if $(DS_PACKAGE_BFTPD_WITH_ZLIB),--enable-libz)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		-C $(BFTPD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(BFTPD_DIR) clean
	rm -f $(BFTPD_DS_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BFTPD_TARGET_BINARY)

$(PKG_FINISH)
