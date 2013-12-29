$(call PKG_INIT_BIN,1.3.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b38df9c431041922c997c1148bedf591
$(PKG)_SITE:=@SF/poptop

$(PKG)_BINARIES:=bcrelay pptpctrl pptpd
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_DEPENDS_ON := pppd

# disable NLS related code
$(PKG)_AC_VARIABLES := lib_c_gettext lib_intl_gettext header_libintl_h
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,$($(PKG)_AC_VARIABLES))
$(PKG)_CONFIGURE_ENV += $(foreach variable,$($(PKG)_AC_VARIABLES),$(pkg)_$(variable)=no)

$(PKG)_CONFIGURE_OPTIONS += --enable-bcrelay

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
# CC/COPTS overrides are necessary because of the plugins subdir (plain Makefile, not controlled by automake)
	$(SUBMAKE) -C $(PPTPD_DIR) \
		CC="$(TARGET_CC)" \
		COPTS="$(TARGET_CFLAGS)" \
		PLUGINS_CFLAGS="-I$(FREETZ_BASE_DIR)/$(PPPD_DIR)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PPTPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PPTPD_BINARIES:%=$(PPTPD_DEST_DIR)/usr/sbin/%)

$(PKG_FINISH)
