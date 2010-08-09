$(call PKG_INIT_BIN, 5.4.3)
$(PKG)_SOURCE:=net-snmp-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3513e39ee1a9d6c7581c508810b818f9
$(PKG)_SITE:=@SF/net-snmp
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/net-snmp-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/agent/.libs/snmpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/snmpd
$(PKG)_TARGET_LIBS:=$($(PKG)_DEST_LIBDIR)/*.so*

NETSNMP_MIB_MODULES_INCLUDED:=\
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
	snmpv3/snmpEngine \
	snmpv3/snmpMPDStats \
	snmpv3/usmStats \
	snmpv3/usmUser \
	tunnel \
	ucd-snmp/disk \
	ucd-snmp/dlmod \
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
	snmpv3mibs \
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
$(PKG)_DEPENDS_ON := openssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_NETSNMP_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NETSNMP_WITH_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NETSNMP_WITH_ZLIB

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-endianness=little
$(PKG)_CONFIGURE_OPTIONS += --with-logfile=/var/log/snmpd.log
$(PKG)_CONFIGURE_OPTIONS += --with-persistent-directory=/var/lib/snmp
$(PKG)_CONFIGURE_OPTIONS += --with-default-snmp-version=1
$(PKG)_CONFIGURE_OPTIONS += --with-sys-contact=root@localhost
$(PKG)_CONFIGURE_OPTIONS += --with-sys-location=Unknown
$(PKG)_CONFIGURE_OPTIONS += --disable-applications
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
$(PKG)_CONFIGURE_OPTIONS += --without-rpm
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NETSNMP_WITH_OPENSSL),,--without-openssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NETSNMP_WITH_ZLIB),,--without-zlib)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(NETSNMP_DIR)
#		LDFLAGS="$(TARGET_LDFLAGS) -lm -ldl"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	mkdir -p $(NETSNMP_DEST_LIBDIR)
	for file in $$(find $(NETSNMP_DIR) -name 'libnetsnmp*.so*'); do \
		cp -d $$file $(NETSNMP_DEST_LIBDIR)/; \
	done
	$(TARGET_STRIP) $(NETSNMP_TARGET_LIBS)

	#mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/net-snmp/agent
	#mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/net-snmp/library
	#cp $(NETSNMP_DIR)/agent/mibgroup/struct.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/net-snmp/agent
	#cp $(NETSNMP_DIR)/agent/mibgroup/util_funcs.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/net-snmp
	#cp $(NETSNMP_DIR)/agent/mibgroup/mibincl.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/net-snmp/library
	#cp $(NETSNMP_DIR)/agent/mibgroup/header_complex.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/net-snmp/agent

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NETSNMP_DIR) clean
	$(RM) $(NETSNMP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(NETSNMP_TARGET_BINARY)
	$(RM) $(NETSNMP_TARGET_LIBS)

$(PKG_FINISH)
