$(call PKG_INIT_BIN, 0.5.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=40dac2970d1048e554e41ca9b5abedbd
$(PKG)_SITE:=@SF/dtmfbox.berlios

$(PKG)_STARTLEVEL=72

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_BINARY_MENU_SO:=$($(PKG)_DIR)/plugins/menu.plugin/.libs/libmenu.plugin.so.0.0.1
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/root/usr/sbin/$(pkg)
$(PKG)_TARGET_BINARY_MENU_SO:=$($(PKG)_TARGET_DIR)/root/usr/lib/libmenu.plugin.so.0.0.1
$(PKG)_CATEGORY:=Unstable

$(PKG)_DEPENDS_ON := libcapi pjproject

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_CAPI
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_VOIP
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_ICE

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_G711_CODEC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_SPEEX_CODEC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_GSM_CODEC
#$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_ILBC_CODEC

# touch some files to prevent aclocal.m4 & configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 configure.in acinclude.m4;

$(PKG)_CONFIGURE_OPTIONS += --with-pjsip-path=$(FREETZ_BASE_DIR)/$($(PKG)_SOURCE_DIR)/pjproject-1.0.1
$(PKG)_CONFIGURE_OPTIONS += --disable-sound
$(PKG)_CONFIGURE_OPTIONS += --disable-template
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_CAPI),,--disable-capi)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_VOIP),,--disable-sip)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_ICE),,--disable-ice)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_BINARY_MENU_SO): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(DTMFBOX_DIR) \
		EXTRA_CFLAGS="-ffunction-sections -fdata-sections" \
		EXTRA_LDFLAGS="-Wl,--gc-sections"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY_MENU_SO): $($(PKG)_BINARY_MENU_SO)
	$(INSTALL_LIBRARY_STRIP)
	for i in "" ".0"; do ln -sf $(notdir $@) $(dir $@)libmenu.plugin.so$$i; done

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_BINARY_MENU_SO)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DTMFBOX_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DTMFBOX_TARGET_BINARY)

$(PKG_FINISH)
