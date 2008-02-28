$(call PKG_INIT_BIN,1.96.2)
$(PKG)_SOURCE:=inadyn.v$($(PKG)_VERSION).zip
$(PKG)_SITE:=http://www.inatech.eu/inadyn
#$(PKG)_SITE:=http://www.mirrorservice.org/sites/ftp.freebsd.org/pub/FreeBSD/distfiles
$(PKG)_DIR:=$(SOURCE_DIR)/inadyn
$(PKG)_BINARY:=$($(PKG)_DIR)/bin/linux/inadyn
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/inadyn

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(INADYN_DIR) \
		CC="mipsel-linux-gcc" \
		STRIP="mipsel-linux-strip" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

inadyn:

inadyn-precompiled: $($(PKG)_TARGET_BINARY)

inadyn-clean:
	-$(MAKE) -C $(INADYN_DIR) clean

inadyn-uninstall:
	$(RM) $(INADYN_TARGET_BINARY)

$(PKG_FINISH)
