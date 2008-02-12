$(call PKG_INIT_BIN, 3.0.24)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://de3.$(pkg).org/pub/$(pkg)/old-versions
$(PKG)_BINARY:=$($(PKG)_DIR)/source/bin/smbd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/smbd
$(PKG)_STARTLEVEL=40

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SAMBA_DIR)/source \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		SAMBA_CFLAGS="$(TARGET_CFLAGS)" \
		CODEPAGEDIR="/mod/usr/share/samba" \
		proto all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SAMBA_DIR)/source clean
	$(RM) -r $(SAMBA_DIR)/source/bin

$(pkg)-uninstall:
	$(RM) $(SAMBA_TARGET_BINARY)

$(PKG_FINISH)
