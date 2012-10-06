$(call PKG_INIT_BIN, 20080406p)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SOURCE_MD5:=655ed0cbc35633e2c424b8fbf42f1d7c
#$(PKG)_SITE:=http://dtucker.freeshell.org/openntpd/snapshot
$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/o/openntpd

$(PKG)_BINARY:=$($(PKG)_DIR)/ntpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ntpd

$(PKG)_STARTLEVEL=60 # before aiccu

$(PKG)_CONFIGURE_ENV += ac_cv_have_decl_asprintf=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_setresuid=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_setresgid=yes

$(PKG)_CONFIGURE_OPTIONS += --with-builtin-arc4random
$(PKG)_CONFIGURE_OPTIONS += --with-privsep-user=ntp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENNTPD_DIR) \
		EXTRA_CPPFLAGS="-D_GNU_SOURCE -DHAVE_ADJTIMEX"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENNTPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OPENNTPD_TARGET_BINARY)

$(PKG_FINISH)
