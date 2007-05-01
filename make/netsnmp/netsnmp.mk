NETSNMP_VERSION:=5.1.2
NETSNMP_SOURCE:=net-snmp-$(NETSNMP_VERSION).tar.gz
NETSNMP_SITE:=http://mesh.dl.sourceforge.net/sourceforge/net-snmp
NETSNMP_DIR:=$(SOURCE_DIR)/net-snmp-$(NETSNMP_VERSION)
NETSNMP_MAKE_DIR:=$(MAKE_DIR)/netsnmp
NETSNMP_TARGET_BINARY:=targetroot/usr/sbin/snmpd
NETSNMP_PKG_VERSION:=0.3
NETSNMP_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
NETSNMP_PKG_NAME:=netsnmp-$(NETSNMP_VERSION)
NETSNMP_PKG_SOURCE:=netsnmp-$(NETSNMP_VERSION)-dsmod-$(NETSNMP_PKG_VERSION).tar.bz2
NETSNMP_TARGET_DIR:=$(PACKAGES_DIR)/$(NETSNMP_PKG_NAME)/root/usr/sbin
NETSNMP_TARGET_LIBS:=targetroot/usr/lib/*.so*
NETSNMP_TARGET_LIBDIR:=$(PACKAGES_DIR)/$(NETSNMP_PKG_NAME)/root/usr/lib

SNMP_MIB_MODULES_INCLUDED:=\
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

SNMP_MIB_MODULES_EXCLUDED:=\
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

SNMP_TRANSPORTS_INCLUDED:=UDP

SNMP_TRANSPORTS_EXCLUDED:=Callback TCP TCPv6 UDPv6 Unix

PKG_CONFIGURE_OPTIONS:=\
  --enable-shared \
  --enable-static \
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
  --with-out-mib-modules="$(SNMP_MIB_MODULES_EXCLUDED)" \
  --with-mib-modules="$(SNMP_MIB_MODULES_INCLUDED)" \
  --with-out-transports="$(SNMP_TRANSPORTS_EXCLUDED)" \
  --with-transports="$(SNMP_TRANSPORTS_INCLUDED)" \
  --without-opaque-special-types \
  --without-openssl \
  --without-libwrap \
  --without-rpm \
  --without-zlib \

$(DL_DIR)/$(NETSNMP_SOURCE):
	wget -P $(DL_DIR) $(NETSNMP_SITE)/$(NETSNMP_SOURCE)

$(DL_DIR)/$(NETSNMP_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(NETSNMP_PKG_SOURCE) $(NETSNMP_PKG_SITE)

$(NETSNMP_DIR)/.unpacked: $(DL_DIR)/$(NETSNMP_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(NETSNMP_SOURCE)
	for i in $(NETSNMP_MAKE_DIR)/patches/*.patch; do \
	    patch -d $(NETSNMP_DIR) -p1 < $$i; \
	done
	touch $@

$(NETSNMP_DIR)/.configured: $(NETSNMP_DIR)/.unpacked
	( cd $(NETSNMP_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
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
		$(PKG_CONFIGURE_OPTIONS) \
	);
	touch $@

$(NETSNMP_DIR)/.built: $(NETSNMP_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(NETSNMP_DIR)
	touch $@

$(NETSNMP_DIR)/.installed: $(NETSNMP_DIR)/.built
	mkdir $(NETSNMP_DIR)/targetroot
	$(MAKE) -C $(NETSNMP_DIR) \
		INSTALL_PREFIX="`pwd`/$(NETSNMP_DIR)/targetroot" \
		install
	touch $@

$(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME): $(DL_DIR)/$(NETSNMP_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(NETSNMP_PKG_SOURCE)
	@touch $@

netsnmp: $(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME)

netsnmp-package: $(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(NETSNMP_PKG_SOURCE) $(NETSNMP_PKG_NAME)

netsnmp-precompiled: $(NETSNMP_DIR)/.installed netsnmp
	$(TARGET_STRIP) $(NETSNMP_DIR)/$(NETSNMP_TARGET_BINARY) \
	                $(NETSNMP_DIR)/$(NETSNMP_TARGET_LIBS)
	mkdir -p $(NETSNMP_TARGET_DIR) $(NETSNMP_TARGET_LIBDIR)
	cp $(NETSNMP_DIR)/$(NETSNMP_TARGET_BINARY) $(NETSNMP_TARGET_DIR)
	cp -a $(NETSNMP_DIR)/$(NETSNMP_TARGET_LIBS) $(NETSNMP_TARGET_LIBDIR)

netsnmp-source: $(NETSNMP_DIR)/.unpacked $(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME)

netsnmp-clean:
	-$(MAKE) -C $(NETSNMP_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(NETSNMP_PKG_SOURCE)

netsnmp-dirclean:
	rm -rf $(NETSNMP_DIR)
	rm -rf $(PACKAGES_DIR)/$(NETSNMP_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(NETSNMP_PKG_NAME)

netsnmp-list:
ifeq ($(strip $(DS_PACKAGE_NETSNMP)),y)
	@echo "S40netsnmp-$(NETSNMP_VERSION)" >> .static
else
	@echo "S40netsnmp-$(NETSNMP_VERSION)" >> .dynamic
endif
