$(call PKG_INIT_BIN, 3-18-39)
$(PKG)_SOURCE:=bfubase.frm
$(PKG)_HASH:=11c1ee570437c930313884c1f396290abef08df931c2c80ec5c4b4ef26af25f6
$(PKG)_SITE:=ftp://ftp.in-berlin.de/pub/capi4linux/firmware/bluefusb/$($(PKG)_VERSION)

$(PKG)_BINARY:=$(DL_DIR)/$($(PKG)_SOURCE)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/lib/firmware/$($(PKG)_SOURCE)

$(PKG_SOURCE_DOWNLOAD)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(PKG_FINISH)
