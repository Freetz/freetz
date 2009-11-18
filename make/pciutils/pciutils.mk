$(call PKG_INIT_BIN,3.0.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.kernel.org/pub/software/utils/pciutils
$(PKG)_BINARY:=$($(PKG)_DIR)/lspci
$(PKG)_SETPCI_BINARY:=$($(PKG)_DIR)/setpci
$(PKG)_IDS:=$($(PKG)_DIR)/pci.ids
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lspci
$(PKG)_SETPCI_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/setpci
$(PKG)_TARGET_IDS:=$($(PKG)_DEST_DIR)/usr/share/pci.ids
$(PKG)_SOURCE_MD5:=85b5dae042217cf11bca10d52210a78d

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY) $($(PKG)_SETPCI_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PCIUTILS_DIR) \
		CC=$(TARGET_CC) \
		CFLAGS="$(TARGET_CFLAGS)" \
		IDSDIR="/usr/share" \
		HOST="$(GNU_TARGET_NAME)" \
		ZLIB="no"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SETPCI_TARGET_BINARY): $($(PKG)_SETPCI_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_IDS): $($(PKG)_IDS)
	$(PCIUTILS_DIR)/update-pciids.sh
	mkdir -p $(dir $@)
	cp $^ $@

$(pkg):

ifeq ($(strip $(FREETZ_PACKAGE_$(PKG)_IDS)),y)
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_SETPCI_TARGET_BINARY) \
		$($(PKG)_TARGET_IDS)
else
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_SETPCI_TARGET_BINARY) \
		$(pkg)-clean-ids
endif

$(pkg)-clean-ids:
	@$(RM) $(PCIUTILS_TARGET_IDS)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PCIUTILS_DIR) clean

$(pkg)-uninstall: $(pkg)-clean-ids
	$(RM) $(PCIUTILS_TARGET_BINARY)
	$(RM) $(PCIUTILS_SETPCI_TARGET_BINARY)

$(PKG_FINISH)
