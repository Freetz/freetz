$(call PKG_INIT_BIN, 4.3.3-P1)
$(PKG)_SOURCE:=dhcp-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=c11e896dffa1bfbc49462965d3f6dec45534e34068603546d9a236f2aa669921
$(PKG)_SITE:=http://ftp.isc.org/isc/dhcp/$($(PKG)_VERSION)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/dhcp-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/server/dhcpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/isc-dhcpd

$(PKG)_DEPENDS_ON += bind

$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -f -i;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# add EXTRA_CFLAGS, EXTRA_LDFLAGS variables to all Makefile.in's
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,^((C|LD)FLAGS)[ \t]*=[ \t]*@\1@,& $$$$(EXTRA_\1),' `find . -name Makefile.in`;

$(PKG)_MAKE_OPTIONS := -C $($(PKG)_DIR)
# reduce binary size by setting appropriate CFLAGS/LDFLAGS
$(PKG)_MAKE_OPTIONS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections"
$(PKG)_MAKE_OPTIONS += EXTRA_LDFLAGS="-Wl,--gc-sections"

$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_random=yes
$(PKG)_CONFIGURE_OPTIONS += --with-libbind="$(BIND_EXPORT_LIB_DIR)/usr"

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
