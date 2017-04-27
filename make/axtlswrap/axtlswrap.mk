$(call PKG_INIT_BIN, 2.1.3)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/axtls-code
$(PKG)_SOURCE:=axTLS-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=1f0f4d0233e9d9709117aa95b039fa15
$(PKG)_SITE:=@SF/axtls

$(PKG)_CATEGORY:=Unstable

$(PKG)_BINARY:=$($(PKG)_DIR)/_stage/axtlswrap
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/axtlswrap

# work around problem with patching source with DOS line endings
$(PKG)_PATCH_PRE_CMDS += $(SED) -i -e 's%\r$$$$%%' axtlswrap/axtlswrap.c

$(PKG)_PATCH_POST_CMDS += cp $(abspath $($(PKG)_MAKE_DIR)/Config.axtls) config/.config;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(AXTLSWRAP_DIR) oldconfig
	$(SUBMAKE) -C $(AXTLSWRAP_DIR) \
		CC="$(TARGET_CC)" \
		OPT_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_CFLAGS="-ffunction-sections -fdata-sections" \
		\
		OPT_LDFLAGS="" \
		EXTRA_LDFLAGS="-Wl,--gc-sections" \
		\
		AR="$(TARGET_AR)" \
		\
		STRIP="true" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(AXTLSWRAP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(AXTLSWRAP_TARGET_BINARY)

$(PKG_FINISH)
