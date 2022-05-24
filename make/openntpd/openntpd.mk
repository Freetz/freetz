$(call PKG_INIT_BIN, 3.9p1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=83dd7c1e8ec8b4567afe49af539271b5a73562fb7a3ca51df73eccba89ec8c49
$(PKG)_SITE:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenNTPD

$(PKG)_BINARY:=$($(PKG)_DIR)/ntpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ntpd

$(PKG)_STARTLEVEL=60

$(PKG)_CONFIGURE_ENV += ac_cv_have_decl_asprintf=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_setresuid=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_setresgid=yes

$(PKG)_CONFIGURE_OPTIONS += --with-builtin-arc4random
$(PKG)_CONFIGURE_OPTIONS += --with-privsep-user=ntp

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
