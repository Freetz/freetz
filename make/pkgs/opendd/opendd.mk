$(call PKG_INIT_BIN, 0.7.9)
$(PKG)_SOURCE:=$(pkg).$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f6b1854f931ddbac096015ac253fc6d2b481f98783ab5ebfbdb89ff4f49da0b5
$(PKG)_SITE:=http://www.bsdmon.com/download/

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_PEM:=$($(PKG)_DIR)/$(pkg).pem
$(PKG)_TARGET_PEM:=$($(PKG)_DEST_DIR)/etc/default.$(pkg)/$(pkg).pem

ifeq ($(strip $(FREETZ_PACKAGE_OPENDD_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_LIBS := -lcrypto -lssl
$(PKG)_OPTS := -DUSE_SOCKET_SSL
$(PKG)_DEPENDS_ON += openssl
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENDD_WITH_SSL

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENDD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		OPTS="$(OPENDD_OPTS)" \
		LIBS="$(OPENDD_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_PEM): $($(PKG)_PEM)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_PEM)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENDD_DIR) clean
	 $(RM) $(OPENDD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(OPENDD_TARGET_BINARY)

$(PKG_FINISH)
