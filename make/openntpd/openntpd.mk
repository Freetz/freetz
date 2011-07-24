$(call PKG_INIT_BIN, 4.9)
$(PKG)_SOURCE:=$(pkg)_portable_pre$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=f37a13f8a44f9b38802e7d9fbe758c0e

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)_portable_pre$($(PKG)_VERSION)
#$(PKG)_SITE:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenNTPD/
# We are using our own openntpd port by TIK
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/ntpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ntpd

$(PKG)_STARTLEVEL=60 # before aiccu

$(PKG)_CONFIGURE_OPTIONS += --with-builtin-arc4random
$(PKG)_CONFIGURE_OPTIONS += --with-privsep-user=ntp
$(PKG)_CONFIGURE_OPTIONS += --with-builtin-md5
$(PKG)_CONFIGURE_OPTIONS += --with-report-signal=SIGUSR1

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENNTPD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENNTPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OPENNTPD_TARGET_BINARY)

$(PKG_FINISH)
