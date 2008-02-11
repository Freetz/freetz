$(call PKG_INIT_BIN, 3.0.24)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://de3.$(pkg).org/pub/$(pkg)/old-versions
$(PKG)_SMBD_BINARY:=$($(PKG)_DIR)/source/bin/smbd
$(PKG)_TARGET_SMBD_BINARY:=$($(PKG)_DEST_DIR)/sbin/smbd
$(PKG)_STARTLEVEL=40

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_SMBD_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SAMBA_DIR)/source \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		SAMBA_CFLAGS="$(TARGET_CFLAGS)" \
		CODEPAGEDIR="/mod/usr/share/samba" \
		proto all

$($(PKG)_TARGET_SMBD_BINARY): $($(PKG)_SMBD_BINARY)
	$(INSTALL_BINARY_STRIP)

samba:

samba-precompiled: $($(PKG)_TARGET_SMBD_BINARY)

samba-clean:
	-$(MAKE) -C $($(PKG)_DIR)/source clean
	rm -rf $($(PKG)_DIR)/source/bin
	rm -f $(PACKAGES_BUILD_DIR)/$($(PKG)_PKG_SOURCE)

samba-uninstall:
	rm -f $($(PKG)_TARGET_SMBD_BINARY)

$(PKG_FINISH)
