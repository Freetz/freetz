$(call PKG_INIT_BIN, 0.5.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=40dac2970d1048e554e41ca9b5abedbd
$(PKG)_SITE:=http://fritz.v3v.de/$(pkg)/$(pkg)-src
$(PKG)_PJPATH:=$(FREETZ_BASE_DIR)/$($(PKG)_SOURCE_DIR)/pjproject-1.0.1
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_BINARY_MENU_SO:=$($(PKG)_DIR)/plugins/menu.plugin/.libs/libmenu.plugin.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/root/usr/sbin/$(pkg)
$(PKG)_TARGET_BINARY_MENU_SO:=$($(PKG)_TARGET_DIR)/root/usr/lib/libmenu.plugin.so
$(PKG)_STARTLEVEL=72

$(PKG)_DEPENDS_ON := libcapi pjproject

$(PKG)_CONFIGURE_OPTIONS := --with-pjsip-path=$(DTMFBOX_PJPATH)
$(PKG)_CONFIGURE_OPTIONS += --prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)
$(PKG)_CONFIGURE_OPTIONS += --exec-prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)
$(PKG)_CONFIGURE_OPTIONS += --disable-sound
$(PKG)_CONFIGURE_OPTIONS += --disable-template
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_CAPI),,--disable-capi)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_VOIP),,--disable-sip)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_ICE),,--disable-ice)

$(call REPLACE_LIBTOOL)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_BINARY_MENU_SO): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(DTMFBOX_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY_MENU_SO): $($(PKG)_BINARY_MENU_SO)
#	$(INSTALL_LIBRARY_STRIP)
	mkdir -p $(dir $@); \
	cp -a $<* $(dir $@)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_BINARY_MENU_SO)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DTMFBOX_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DTMFBOX_TARGET_BINARY)

$(PKG_FINISH)
