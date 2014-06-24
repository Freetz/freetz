$(call PKG_INIT_BIN, 3.1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3be148772a33224771a8d4d2a028b132
$(PKG)_SITE:=http://samba.org/ftp/rsync/src

$(PKG)_BINARY:=$($(PKG)_DIR)/rsync
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/rsync

$(PKG)_DEPENDS_ON := popt

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

# rsync sets some C99 related options, not all packages are C99 compliant, so make the following values rsync specific
$(PKG)_AC_VARIABLES := prog_cc_c89 prog_cc_c99 prog_cc_stdc
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,$($(PKG)_AC_VARIABLES),./configure.sh)

$(PKG)_CONFIGURE_OPTIONS += --disable-iconv
$(PKG)_CONFIGURE_OPTIONS += --disable-locale
$(PKG)_CONFIGURE_OPTIONS += --without-included-popt
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RSYNC_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RSYNC_DIR) clean
	$(RM) $(RSYNC_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(RSYNC_TARGET_BINARY)

$(PKG_FINISH)
