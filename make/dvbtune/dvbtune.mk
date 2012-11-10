$(call PKG_INIT_BIN, 0.5)
$(PKG)_SOURCE:=dvbtune-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=5212564c786f2538db753214e0e21473
$(PKG)_SITE:=@SF/dvbtools
$(PKG)_BINARY:=$($(PKG)_DIR)/dvbtune
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dvbtune

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DVBTUNE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DNEWSTRUCT" \

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DVBTUNE_DIR) clean
	$(RM) $(DVBTUNE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DVBTUNE_TARGET_BINARY)

$(PKG_FINISH)
