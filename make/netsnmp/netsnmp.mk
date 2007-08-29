NETSNMP_VERSION:=5.1.2
NETSNMP_SOURCE:=net-snmp-$(NETSNMP_VERSION).tar.gz
NETSNMP_SITE:=http://mesh.dl.sourceforge.net/sourceforge/net-snmp
NETSNMP_MAKE_DIR:=$(MAKE_DIR)/netsnmp
NETSNMP_DIR:=$(SOURCE_DIR)/net-snmp-$(NETSNMP_VERSION)
NETSNMP_BINARY:=$(NETSNMP_DIR)/agent/.libs/snmpd
NETSNMP_PKG_VERSION:=0.4b
NETSNMP_PKG_SITE:=http://www.heimpold.de/dsmod
NETSNMP_PKG_NAME:=netsnmp-$(NETSNMP_VERSION)
NETSNMP_PKG_SOURCE:=netsnmp-$(NETSNMP_VERSION)-dsmod-$(NETSNMP_PKG_VERSION).tar.bz2
NETSNMP_TARGET_DIR:=$(PACKAGES_DIR)/$(NETSNMP_PKG_NAME)
NETSNMP_TARGET_BINARY:=$(NETSNMP_TARGET_DIR)/root/usr/sbin/snmpd
NETSNMP_TARGET_LIBS:=$(NETSNMP_TARGET_DIR)/root/usr/lib/*.so*

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
  mibII/interfaces \
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
  snmpv3mibs \
  tunnel \
  ucd-snmp/disk \
  ucd-snmp/extensible \
  ucd-snmp/loadave \
  ucd-snmp/memory \
  ucd-snmp/pass \
  ucd-snmp/proc \
  ucd-snmp/vmstat \
  util_funcs \
  utilities/execute \

NETSNMP_MIB_MODULES_EXCLUDED:=\
  agent_mibs \
  agentx \
  host \
  ieee802dot11 \
  mibII \
  notification \
  snmpv3mibs \
  target \
  ucd_snmp \
  utilities \

NETSNMP_TRANSPORTS_INCLUDED:=UDP

NETSNMP_TRANSPORTS_EXCLUDED:=Callback TCP TCPv6 UDPv6 Unix

ifeq ($(strip $(DS_PACKAGE_NETSNMP_WITH_OPENSSL)),y)
NETSNMP_OPENSSL:=openssl-precompiled
else
NETSNMP_OPENSSL:=
endif

ifeq ($(strip $(DS_PACKAGE_NETSNMP_WITH_ZLIB)),y)
NETSNMP_ZLIB:=zlib-precompiled
else
NETSNMP_ZLIB:=
endif

NETSNMP_DS_CONFIG_FILE:=$(NETSNMP_MAKE_DIR)/.ds_config
NETSNMP_DS_CONFIG_TEMP:=$(NETSNMP_MAKE_DIR)/.ds_config.temp

NETSNMP_PKG_CONFIGURE_OPTIONS:=\
  --enable-shared \
  --disable-static \
  --with-endianness=little \
  --with-logfile=/var/log/snmpd.log \
  --with-persistent-directory=/var/lib/snmp \
  --with-default-snmp-version=1 \
  --with-sys-contact=root@localhost \
  --with-sys-location=Unknown \
  --disable-applications \
  --disable-debugging \
  --disable-ipv6 \
  --disable-manuals \
  --disable-mib-loading \
  --disable-mibs \
  --disable-scripts \
  --with-out-mib-modules="$(NETSNMP_MIB_MODULES_EXCLUDED)" \
  --with-mib-modules="$(NETSNMP_MIB_MODULES_INCLUDED)" \
  --with-out-transports="$(NETSNMP_TRANSPORTS_EXCLUDED)" \
  --with-transports="$(NETSNMP_TRANSPORTS_INCLUDED)" \
  --without-opaque-special-types \
  $(if $(DS_PACKAGE_NETSNMP_WITH_OPENSSL),,--without-openssl) \
  --without-libwrap \
  --without-rpm \
  $(if $(DS_PACKAGE_NETSNMP_WITH_ZLIB),,--without-zlib) \

$(DL_DIR)/$(NETSNMP_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(NETSNMP_SITE)/$(NETSNMP_SOURCE)

$(DL_DIR)/$(NETSNMP_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(NETSNMP_PKG_SOURCE) $(NETSNMP_PKG_SITE)

$(NETSNMP_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_PACKAGE_NETSNMP_WITH_OPENSSL=$(if $(DS_PACKAGE_NETSNMP_WITH_OPENSSL),y,n)" > $(NETSNMP_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_NETSNMP_WITH_ZLIB=$(if $(DS_PACKAGE_NETSNMP_WITH_ZLIB),y,n)" > $(NETSNMP_DS_CONFIG_TEMP)
	@diff -q $(NETSNMP_DS_CONFIG_TEMP) $(NETSNMP_DS_CONFIG_FILE) || \
		cp $(NETSNMP_DS_CONFIG_TEMP) $(NETSNMP_DS_CONFIG_FILE)
	@rm -f $(NETSNMP_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(NETSNMP_DIR)/.unpacked: $(DL_DIR)/$(NETSNMP_SOURCE) $(NETSNMP_DS_CONFIG_FILE)
	rm -rf $(NETSNMP_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(NETSNMP_SOURCE)
	for i in $(NETSNMP_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(NETSNMP_DIR) $$i; \
	done
	touch $@

$(NETSNMP_DIR)/.configured: $(NETSNMP_DIR)/.unpacked
	( cd $(NETSNMP_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		ac_cv_CAN_USE_SYSCTL=no \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--datadir=/usr/share \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--libdir=/usr/lib \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--mandir=/usr/share/man \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		$(NETSNMP_PKG_CONFIGURE_OPTIONS) \
	);
	touch $@
	
$(NETSNMP_BINARY): $(NETSNMP_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE1) -C $(NETSNMP_DIR)

$(NETSNMP_TARGET_BINARY): $(NETSNMP_BINARY)
	$(INSTALL_BINARY_STRIP)
	for file in $$(find $(NETSNMP_DIR) -name 'libnetsnmp*.so*'); do \
		cp -d $$file $(NETSNMP_TARGET_DIR)/root/usr/lib/; \
	done
	$(TARGET_STRIP) $(NETSNMP_TARGET_LIBS)

	mkdir -p $(TARGET_MAKE_PATH)/../include/net-snmp/agent
	mkdir -p $(TARGET_MAKE_PATH)/../include/net-snmp/library
	cp $(NETSNMP_DIR)/agent/mibgroup/struct.h $(TARGET_MAKE_PATH)/../include/net-snmp/agent
	cp $(NETSNMP_DIR)/agent/mibgroup/util_funcs.h $(TARGET_MAKE_PATH)/../include/net-snmp
	cp $(NETSNMP_DIR)/agent/mibgroup/mibincl.h $(TARGET_MAKE_PATH)/../include/net-snmp/library
	cp $(NETSNMP_DIR)/agent/mibgroup/header_complex.h $(TARGET_MAKE_PATH)/../include/net-snmp/agent

$(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME): $(DL_DIR)/$(NETSNMP_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(NETSNMP_PKG_SOURCE)
	@touch $@

netsnmp: $(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME)

netsnmp-package: $(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(NETSNMP_PKG_SOURCE) $(NETSNMP_PKG_NAME)

netsnmp-precompiled: uclibc $(NETSNMP_OPENSSL) $(NETSNMP_ZLIB) netsnmp $(NETSNMP_TARGET_BINARY) 

netsnmp-source: $(NETSNMP_DIR)/.unpacked $(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME)

netsnmp-clean:
	-$(MAKE) -C $(NETSNMP_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(NETSNMP_PKG_SOURCE)
	rm -f $(NETSNMP_DS_CONFIG_FILE)

netsnmp-dirclean:
	rm -rf $(NETSNMP_DIR)
	rm -rf $(PACKAGES_DIR)/$(NETSNMP_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME)
	rm -f $(NETSNMP_DS_CONFIG_FILE)

netsnmp-uninstall:
	rm -f $(NETSNMP_TARGET_BINARY) 
	rm -f $(NETSNMP_TARGET_LIBS)

netsnmp-list:
ifeq ($(strip $(DS_PACKAGE_NETSNMP)),y)
	@echo "S40netsnmp-$(NETSNMP_VERSION)" >> .static
else
	@echo "S40netsnmp-$(NETSNMP_VERSION)" >> .dynamic
endif
