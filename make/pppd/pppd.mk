$(call PKG_INIT_BIN, 2.4.4)
$(PKG)_SOURCE:=ppp-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.samba.org/pub/ppp
$(PKG)_DIR:=$(SOURCE_DIR)/ppp-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/pppd/pppd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/pppd
$(PKG)_STARTLEVEL=40

$(PKG)_DEPENDS_ON := libpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) \
	CC="$(TARGET_CC)" \
	COPTS="$(TARGET_CFLAGS)" \
	STAGING_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	-C $(PPPD_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PPPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PPPD_TARGET_BINARY)

$(PKG_FINISH)
