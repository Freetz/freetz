$(call PKG_INIT_BIN, 0.2.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=5be3c765af3c5f518d1e1bbd828b3582ad4097cd
$(PKG)_SITE:=http://$(pkg).googlecode.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_USE_POLARSSL

$(PKG)_DEPENDS_ON := libconfig protobuf-c
ifeq ($(strip $(FREETZ_PACKAGE_UMURMUR_USE_POLARSSL)),y)
$(PKG)_DEPENDS_ON += polarssl
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=polarssl
$(PKG)_CONFIGURE_OPTIONS += --disable-polarssl-test-certificate
$(PKG)_CONFIGURE_OPTIONS += --disable-polarssl-havege
else
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UMURMUR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UMURMUR_DIR) clean
	$(RM) $(UMURMUR_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UMURMUR_TARGET_BINARY)

$(PKG_FINISH)
