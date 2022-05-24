$(call PKG_INIT_BIN,1.4.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=8fcd8b8a42de2af59e9fe8cbaa9f894045c977f4d038bbd6346a8522bb7f06c0
$(PKG)_SITE:=@SF/poptop

$(PKG)_BINARIES:=bcrelay pptpctrl pptpd
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_PLUGINS:=pptpd-logwtmp.so
$(PKG)_PLUGINS_BUILD_DIR:=$($(PKG)_PLUGINS:%=$($(PKG)_DIR)/plugins/%)
$(PKG)_PLUGINS_TARGET_DIR:=$($(PKG)_PLUGINS:%=$($(PKG)_DEST_DIR)/usr/lib/pptpd/%)

$(PKG)_DEPENDS_ON += pppd

# disable NLS related code
$(PKG)_AC_VARIABLES := lib_c_gettext lib_intl_gettext header_libintl_h
$(PKG)_CONFIGURE_ENV += $(foreach variable,$($(PKG)_AC_VARIABLES),ac_cv_$(variable)=no)

$(PKG)_CONFIGURE_OPTIONS += --enable-bcrelay

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_PLUGINS_BUILD_DIR): $($(PKG)_DIR)/.configured
# CC/COPTS overrides are necessary because of the plugins subdir (plain Makefile, not controlled by automake)
	$(SUBMAKE) -C $(PPTPD_DIR) \
		CC="$(TARGET_CC)" \
		COPTS="$(TARGET_CFLAGS)" \
		PLUGINS_CFLAGS="-I$(FREETZ_BASE_DIR)/$(PPPD_DIR)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_PLUGINS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/lib/pptpd/%: $($(PKG)_DIR)/plugins/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_PLUGINS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PPTPD_DIR) clean

$(pkg)-uninstall:
	$(RM) \
		$(PPTPD_BINARIES:%=$(PPTPD_DEST_DIR)/usr/sbin/%) \
		$(PPTPD_PLUGINS:%=$(PPTPD_DEST_DIR)/usr/lib/pptpd/%)

$(PKG_FINISH)
