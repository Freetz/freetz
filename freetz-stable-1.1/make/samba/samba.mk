$(call PKG_INIT_BIN, 3.0.24)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://de3.$(pkg).org/pub/$(pkg)/old-versions
$(PKG)_SMBP_BINARY:=$($(PKG)_DIR)/source/bin/smbpasswd
$(PKG)_SMBP_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/smbpasswd
$(PKG)_SMBD_BINARY:=$($(PKG)_DIR)/source/bin/smbd
$(PKG)_SMBD_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/smbd
$(PKG)_NMBD_BINARY:=$($(PKG)_DIR)/source/bin/nmbd
$(PKG)_NMBD_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/nmbd
$(PKG)_STARTLEVEL=80

#$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NMBD

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_SMBP_BINARY) $($(PKG)_SMBD_BINARY) $($(PKG)_NMBD_BINARY): $($(PKG)_DIR)/.configured
		PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SAMBA_DIR)/source \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		SAMBA_CFLAGS="$(TARGET_CFLAGS)" \
		CODEPAGEDIR="/mod/usr/share/samba" \
		proto
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SAMBA_DIR)/source \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		SAMBA_CFLAGS="$(TARGET_CFLAGS)" \
		CODEPAGEDIR="/mod/usr/share/samba" \
		all

$($(PKG)_SMBP_TARGET_BINARY): $($(PKG)_SMBP_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SMBD_TARGET_BINARY): $($(PKG)_SMBD_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_NMBD_TARGET_BINARY): $($(PKG)_NMBD_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

ifeq ($(strip $(FREETZ_PACKAGE_NMBD)),y)
$(pkg)-precompiled: $($(PKG)_SMBP_TARGET_BINARY) $($(PKG)_SMBD_TARGET_BINARY) $($(PKG)_NMBD_TARGET_BINARY)
else
$(pkg)-precompiled: $($(PKG)_SMBP_TARGET_BINARY) $($(PKG)_SMBD_TARGET_BINARY) $(pkg)-clean-nmbd
endif

$(pkg)-clean-nmbd:
	$(RM) $(SAMBA_NMBD_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SAMBA_DIR)/source clean
	$(RM) -r $(SAMBA_DIR)/source/bin

$(pkg)-uninstall:
	$(RM) $(SAMBA_SMBP_TARGET_BINARY) \
		$(SAMBA_SMBD_TARGET_BINARY) \
		$(SAMBA_NMBD_TARGET_BINARY)

$(PKG_FINISH)
