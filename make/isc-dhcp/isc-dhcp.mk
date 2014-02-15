$(call PKG_INIT_BIN, 4.2.5-P1)
$(PKG)_SOURCE:=dhcp-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=f68e3c1f00a9af5742bc5e71d567cf93
$(PKG)_SITE:=http://ftp.isc.org/isc/dhcp/$($(PKG)_VERSION)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/dhcp-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/server/dhcpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/isc-dhcpd

$(PKG)_DEPENDS_ON += bind

$(PKG)_MAKE_OPTIONS := -C $($(PKG)_DIR)

$(PKG)_AVOID_AUTORECONF:=y

ifeq ($($(PKG)_AVOID_AUTORECONF),y)
# do not process bind subdir while making dhcp
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e '/^SUBDIRS[ \t]*=/ s,bind,,' Makefile.in;
# replace ../bind and ../../bind with $(libbind) in all Makefile.in's
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,(../)+bind/,$$$$(libbind)/,g' `find . -name Makefile.in`;
$(PKG)_MAKE_OPTIONS += libbind="$(BIND_EXPORT_LIB_DIR)"
else
# this branch requires 010-external_libbind_support.patch
$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -f -i;
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-libbind="$(BIND_EXPORT_LIB_DIR)"

# add EXTRA_CFLAGS, EXTRA_LDFLAGS variables to all Makefile.in's
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,^((C|LD)FLAGS)[ \t]*=[ \t]*@\1@,& $$$$(EXTRA_\1),' `find . -name Makefile.in`;

# reduce binary size by setting appropriate CFLAGS/LDFLAGS
$(PKG)_MAKE_OPTIONS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections"
$(PKG)_MAKE_OPTIONS += EXTRA_LDFLAGS="-Wl,--gc-sections"

$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_random=yes

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
