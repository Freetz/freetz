$(call PKG_INIT_BIN,2.25)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ae3729ab5592be06ed01b973d4b3e9fe
$(PKG)_SITE:=http://bluez.sourceforge.net/download

$(PKG)_BIN_BINARIES:=dund pand rfcomm l2ping sdptool
$(PKG)_BIN_BINARIES_BUILD_DIR:=$(addprefix $($(PKG)_DIR)/,$(join dund/ pand/ rfcomm/ tools/ tools/,$($(PKG)_BIN_BINARIES)))

$(PKG)_SBIN_BINARIES:=hcid sdpd hciconfig hcitool
$(PKG)_SBIN_BINARIES_BUILD_DIR:=$(addprefix $($(PKG)_DIR)/,$(join hcid/ sdpd/ tools/ tools/,$($(PKG)_SBIN_BINARIES)))

$(PKG)_BINARIES_TARGET_DIR:=$(addprefix $($(PKG)_DEST_DIR)/usr/bin/,$($(PKG)_BIN_BINARIES)) $(addprefix $($(PKG)_DEST_DIR)/usr/sbin/,$($(PKG)_SBIN_BINARIES))

$(PKG)_DEPENDS_ON := bluez-libs

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# as we (want to) build the package with no libusb support, change prefix of libusb related variables to ensure that no libusb dependent package is affected
# as of version 2.25 --with-usb=no option doesn't affect anything, so we have to set ac_variable explcitly in order to get bluez-utils built with no usb support
$(PKG)_CONFIGURE_OPTIONS += --with-usb=no
$(PKG)_AC_VARIABLES := header_usb_h lib_usb_usb_open lib_usb_usb_get_busses lib_usb_usb_interrupt_read
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,$($(PKG)_AC_VARIABLES))
$(PKG)_CONFIGURE_ENV += $(foreach ac_variable,$($(PKG)_AC_VARIABLES),bluez_utils_cv_$(ac_variable)=no)

# bluez-utils code is not C99 compliant
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,prog_cc_stdc)
$(PKG)_CONFIGURE_ENV += bluez_utils_cv_prog_cc_stdc=no

$(PKG)_CONFIGURE_OPTIONS +=--disable-dbus
$(PKG)_CONFIGURE_OPTIONS +=--disable-fuse
$(PKG)_CONFIGURE_OPTIONS +=--disable-obex
$(PKG)_CONFIGURE_OPTIONS +=--disable-alsa
$(PKG)_CONFIGURE_OPTIONS +=--disable-test
$(PKG)_CONFIGURE_OPTIONS +=--disable-cups
$(PKG)_CONFIGURE_OPTIONS +=--disable-pcmcia
$(PKG)_CONFIGURE_OPTIONS +=--disable-initscripts
$(PKG)_CONFIGURE_OPTIONS +=--disable-bccmd
$(PKG)_CONFIGURE_OPTIONS +=--disable-avctrl
$(PKG)_CONFIGURE_OPTIONS +=--disable-hid2hci
$(PKG)_CONFIGURE_OPTIONS +=--disable-dfutool
$(PKG)_CONFIGURE_OPTIONS +=--disable-bcm203x
$(PKG)_CONFIGURE_OPTIONS +=--disable-bluepin
$(PKG)_CONFIGURE_OPTIONS +=--with-bluez="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BIN_BINARIES_BUILD_DIR) $($(PKG)_SBIN_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(BLUEZ_UTILS_DIR)

define BLUEZ_UTILS_INSTALL_BINARY_STRIP
$($(PKG)_DEST_DIR)$(strip $(2))/$(notdir $(strip $(1))): $(strip $(1))
	$(value INSTALL_BINARY_STRIP)
endef
$(foreach binary,$($(PKG)_BIN_BINARIES_BUILD_DIR),$(eval $(call BLUEZ_UTILS_INSTALL_BINARY_STRIP,$(binary),/usr/bin)))
$(foreach binary,$($(PKG)_SBIN_BINARIES_BUILD_DIR),$(eval $(call BLUEZ_UTILS_INSTALL_BINARY_STRIP,$(binary),/usr/sbin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(MAKE) -C $(BLUEZ_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BLUEZ_UTILS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
