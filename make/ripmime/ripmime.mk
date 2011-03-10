$(call PKG_INIT_BIN, 1.2.16.21)
#$(call PKG_INIT_BIN, 1.4.0.9)
$(PKG)_SOURCE:=ripmime-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.pldaniels.com/ripmime
$(PKG)_BINARY:=$($(PKG)_DIR)/ripmime
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ripmime
#1.2.16.21
$(PKG)_SOURCE_MD5:=c57e4891cb6a73aed810f69d00414f1e 
#1.4.0.9
#$(PKG)_SOURCE_MD5:=25761b8a533bc935f75902724fb73244

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RIPMIME_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RIPMIME_DIR) clean
	$(RM) $(RIPMIME_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(RIPMIME_TARGET_BINARY)

$(PKG_FINISH)
