$(call PKG_INIT_BIN, 5.9.1)
$(PKG)_SOURCE:=net-snmp-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=eb7fd4a44de6cddbffd9a92a85ad1309e5c1054fb9d5a7dd93079c8953f48c3f
$(PKG)_SITE:=@SF/net-snmp
### WEBSITE:=http://www.net-snmp.org/
### MANPAGE:=http://www.net-snmp.org/docs/man/
### CHANGES:=http://www.net-snmp.org/download.html
### CVSREPO:=https://github.com/net-snmp/net-snmp

$(PKG)_BINARY:=$($(PKG)_DIR)/agent/.libs/snmpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/snmpd

# Applications selected
$(PKG)_APPS:= encode_keychange snmpbulkget snmpbulkwalk snmpdelta snmpdf snmpget snmpgetnext snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
$(PKG)_APPS_INCLUDED    := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_APPS))
$(PKG)_APPS_BUILD_DIR   := $(addprefix $($(PKG)_DIR)/apps/.libs/,$($(PKG)_APPS_INCLUDED))
$(PKG)_APPS_TARGET_DIR  := $(addprefix $($(PKG)_DEST_DIR)/usr/bin/,$($(PKG)_APPS_INCLUDED))

# Libraries
$(PKG)_LIB_VERISON:=40.1.0
$(PKG)_LIB_SUFFIX:=so.$($(PKG)_LIB_VERISON)
$(PKG)_LIBNAMES_SHORT:=snmp snmpagent snmpmibs snmphelpers
ifneq ($(filter snmptrap%,$(NETSNMP_APPS_INCLUDED)),)
$(PKG)_LIBNAMES_SHORT+= snmptrapd
endif
$(PKG)_LIBNAMES_LONG:=$($(PKG)_LIBNAMES_SHORT:%=libnet%.$($(PKG)_LIB_SUFFIX))
$(PKG)_LIBS_BUILD_DIR_SHORT:=snmplib agent agent agent/helpers
ifneq ($(filter snmptrap%,$(NETSNMP_APPS_INCLUDED)),)
$(PKG)_LIBS_BUILD_DIR_SHORT+= apps
endif
$(PKG)_LIBS_BUILD_DIR:=$(join $($(PKG)_LIBS_BUILD_DIR_SHORT:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_LIBNAMES_LONG))
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DEST_LIBDIR)/%)

NETSNMP_MIB_MODULES_INCLUDED:=\
	agent/extend \
	host/hr_device \
	host/hr_disk \
	host/hr_filesys \
	host/hr_network \
	host/hr_partition \
	host/hr_proc \
	host/hr_storage \
	host/hr_system \
	mibII/at \
	mibII/icmp \
	mibII/ifTable \
	mibII/ip \
	mibII/snmp_mib \
	mibII/sysORTable \
	mibII/system_mib \
	mibII/tcp \
	mibII/udp \
	mibII/vacm_context \
	mibII/vacm_vars \
	snmpv3mibs \
	snmpv3/snmpEngine \
	snmpv3/usmUser \
	tunnel \
	ucd-snmp/disk \
	ucd-snmp/extensible \
	ucd-snmp/loadave \
	ucd-snmp/memory \
	ucd-snmp/pass \
	ucd-snmp/proc \
	ucd-snmp/vmstat \
	util_funcs \
	utilities/execute

NETSNMP_MIB_MODULES_EXCLUDED:=\
	agent_mibs \
	agentx \
	disman/event \
	disman/schedule \
	host \
	ieee802dot11 \
	if-mib \
	mibII \
	notification \
	notification-log-mib \
	target \
	tcp-mib \
	ucd_snmp \
	udp-mib \
	utilities

NETSNMP_TRANSPORTS_INCLUDED:=Callback UDP

NETSNMP_TRANSPORTS_EXCLUDED:=TCP TCPIPv6 Unix

ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
NETSNMP_TRANSPORTS_INCLUDED+=UDPIPv6
$(PKG)_CONFIGURE_OPTIONS += --enable-ipv6
endif

ifeq ($(strip $(FREETZ_PACKAGE_NETSNMP_WITH_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_NETSNMP_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NETSNMP_WITH_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NETSNMP_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NETSNMP_WITH_APPLICATIONS
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-endianness=$(if $(FREETZ_TARGET_ARCH_BE),big,little)
$(PKG)_CONFIGURE_OPTIONS += --with-logfile=/var/log/snmpd.log
$(PKG)_CONFIGURE_OPTIONS += --with-persistent-directory=/var/lib/snmp
$(PKG)_CONFIGURE_OPTIONS += --with-default-snmp-version=1
$(PKG)_CONFIGURE_OPTIONS += --with-sys-contact=root@localhost
$(PKG)_CONFIGURE_OPTIONS += --with-sys-location=Unknown
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NETSNMP_WITH_APPLICATIONS),--enable-applications,--disable-applications)
$(PKG)_CONFIGURE_OPTIONS += --disable-debugging
$(PKG)_CONFIGURE_OPTIONS += --disable-manuals
$(PKG)_CONFIGURE_OPTIONS += --disable-mib-loading
$(PKG)_CONFIGURE_OPTIONS += --disable-mibs
$(PKG)_CONFIGURE_OPTIONS += --disable-scripts
$(PKG)_CONFIGURE_OPTIONS += --with-out-mib-modules="$(NETSNMP_MIB_MODULES_EXCLUDED)"
$(PKG)_CONFIGURE_OPTIONS += --with-mib-modules="$(NETSNMP_MIB_MODULES_INCLUDED)"
$(PKG)_CONFIGURE_OPTIONS += --with-out-transports="$(NETSNMP_TRANSPORTS_EXCLUDED)"
$(PKG)_CONFIGURE_OPTIONS += --with-transports="$(NETSNMP_TRANSPORTS_INCLUDED)"
$(PKG)_CONFIGURE_OPTIONS += --without-opaque-special-types
$(PKG)_CONFIGURE_OPTIONS += --without-elf
$(PKG)_CONFIGURE_OPTIONS += --without-libwrap
$(PKG)_CONFIGURE_OPTIONS += --without-mysql
$(PKG)_CONFIGURE_OPTIONS += --without-rpm
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NETSNMP_WITH_OPENSSL),,--without-openssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NETSNMP_WITH_ZLIB),,--without-zlib)
$(PKG)_CONFIGURE_OPTIONS += --disable-perl-cc-checks
$(PKG)_CONFIGURE_OPTIONS += --disable-embedded-perl
$(PKG)_CONFIGURE_OPTIONS += --without-perl-modules


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIBS_BUILD_DIR) $($(PKG)_APPS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(NETSNMP_DIR) \
		LDFLAGS="$(TARGET_LDFLAGS) -ldl"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(foreach library,$($(PKG)_LIBS_BUILD_DIR),$(eval $(call INSTALL_LIBRARY_STRIP_RULE,$(library),$(FREETZ_LIBRARY_DIR))))
$(foreach app,$(NETSNMP_APPS_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(app),/usr/bin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_APPS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(NETSNMP_DIR) clean
	$(RM) $(NETSNMP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(NETSNMP_TARGET_BINARY)
	$(RM) $(NETSNMP_LIBS_TARGET_DIR)

$(PKG_FINISH)
