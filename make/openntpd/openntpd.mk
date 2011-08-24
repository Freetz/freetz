$(call PKG_INIT_BIN, 4.9.1)
$(PKG)_SOURCE:=portable_$(pkg)_v$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=aeed0fd9084cd99a7d5f8bf6ba13ce7d

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/portable_$(pkg)_v$($(PKG)_VERSION)
#$(PKG)_SITE:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenNTPD/
# We are using our own openntpd port by TIK
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/pntpd
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
