$(call PKG_INIT_BIN, 4.3.6-P1)
$(PKG)_SOURCE:=dhcp-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=2fd177bef02856f05fe17713ced9bfcc7d94f14c933c15f2f2fbedc9cc57a3c3
$(PKG)_SITE:=http://ftp.isc.org/isc/dhcp/$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/server/dhcpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/isc-dhcpd

$(PKG)_DEPENDS_ON += bind

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS)

$(PKG)_MAKE_OPTIONS := -C $($(PKG)_DIR)
# reduce binary size by setting appropriate CFLAGS/LDFLAGS
$(PKG)_MAKE_OPTIONS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections"
$(PKG)_MAKE_OPTIONS += EXTRA_LDFLAGS="-Wl,--gc-sections"

$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_random=yes
$(PKG)_CONFIGURE_OPTIONS += --with-randomdev="/dev/random"
$(PKG)_CONFIGURE_OPTIONS += --with-libbind="$(BIND_EXPORT_LIB_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-paranoia
$(PKG)_CONFIGURE_OPTIONS += --enable-early-chroot

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(ISC_DHCP_MAKE_OPTIONS)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) $(ISC_DHCP_MAKE_OPTIONS) clean

$(pkg)-uninstall:
	$(RM) $(ISC_DHCP_TARGET_BINARY)

$(PKG_FINISH)
