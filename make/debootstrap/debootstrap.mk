$(call PKG_INIT_BIN, 0.3.3.2)
$(PKG)_SOURCE:=debootstrap_$(DEBOOTSTRAP_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/d/debootstrap
$(PKG)_BINARY:=$($(PKG)_DIR)/pkgdetails
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/debootstrap/pkgdetails

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	cd $(DEBOOTSTRAP_DIR) && $(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CC) $(TARGET_CFLAGS) -o pkgdetails pkgdetails.c

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(DEBOOTSTRAP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DEBOOTSTRAP_TARGET_BINARY)

$(PKG_FINISH)
