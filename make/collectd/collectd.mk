COLLECTD_VERSION:=4.0.5
COLLECTD_SOURCE:=collectd-$(COLLECTD_VERSION).tar.gz
COLLECTD_SITE:=http://collectd.org/files
COLLECTD_MAKE_DIR:=$(MAKE_DIR)/collectd
COLLECTD_DIR:=$(SOURCE_DIR)/collectd-$(COLLECTD_VERSION)
COLLECTD_BINARY:=$(COLLECTD_DIR)/collectd
COLLECTD_TARGET_DIR:=$(PACKAGES_DIR)/collectd-$(COLLECTD_VERSION)
COLLECTD_TARGET_BINARY:=$(COLLECTD_TARGET_DIR)/root/usr/bin/collectd
#COLLECTD_PKG_VERSION:=0.1
#COLLECTD_PKG_SOURCE:=collectd-$(COLLECTD_VERSION)-dsmod-$(COLLECTD_PKG_VERSION).tar.bz2
#COLLECTD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

#$(DL_DIR)/$(COLLECTD_SOURCE): | $(DL_DIR)
#	wget -P $(DL_DIR) $(COLLECTD_SITE)/$(COLLECTD_SOURCE)
#
#$(DL_DIR)/$(COLLECTD_PKG_SOURCE): | $(DL_DIR)
#	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(COLLECTD_PKG_SOURCE) $(COLLECTD_PKG_SITE)

$(COLLECTD_DIR)/.unpacked: $(DL_DIR)/$(COLLECTD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(COLLECTD_SOURCE)
#	for i in $(COLLECTD_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(COLLECTD_DIR) -p1 < $$i; \
#	done
	touch $@

$(COLLECTD_DIR)/.configured: $(COLLECTD_DIR)/.unpacked
	( cd $(COLLECTD_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
 		--disable-apache        disable Apache httpd statistics \
 		--disable-apcups        disable Statistics of UPSes by APC \
 		--disable-apple_sensors disable Apple's hardware sensors \
 		--disable-battery       disable battery statistics \
 		--disable-cpu           disable cpu usage statistics \
 		--disable-cpufreq       disable system cpu frequency statistics \
  		--disable-disk          disable disk/partition statistics \
		--disable-csv           disable csv output plugin \
  		--disable-df            disable df statistics \
  		--disable-dns           disable dns statistics \
  		--disable-email         disable email statistics \
  		--disable-entropy       disable entropy statistics \
  		--disable-exec          disable exec of external programs \
  		--disable-hddtemp       disable hdd temperature statistics \
  		--disable-interface     disable interface statistics \
  		--disable-iptables      disable IPtables statistics \
  		--disable-irq           disable irq statistics \
  		--disable-load          disable system load statistics \
  		--disable-mbmon         disable motherboard monitor statistics \
  		--disable-memory        disable memory statistics \
  		--disable-multimeter    disable multimeter statistics \
  		--disable-mysql         disable mysql statistics \
  		--disable-network       disable network functionality \
  		--disable-nfs           disable nfs statistics \
  		--disable-ntpd          disable ntpd statistics \
  		--disable-nut           disable network UPS tools statistics \
  		--disable-perl          disable embedded perl interpreter \
  		--disable-ping          disable ping statistics \
  		--disable-processes     disable processes statistics \
  		--disable-sensors       disable lm_sensors statistics \
  		--disable-serial        disable serial statistics \
  		--disable-logfile       disable logfile log facility \
  		--disable-swap          disable swap statistics \
  		--disable-syslog        disable syslog log facility \
  		--disable-tape          disable tape statistics \
  		--disable-unixsock      disable UNIX socket plugin \
  		--disable-users         disable user count statistics \
  		--disable-vserver       disable vserver statistics \
  		--disable-wireless      disable wireless link statistics \
	);
	touch $@

$(COLLECTD_BINARY): $(COLLECTD_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(COLLECTD_DIR)

$(COLLECTD_TARGET_BINARY): $(COLLECTD_BINARY)
	$(INSTALL_BINARY_STRIP)
	@# Don't copy these, because they are already part of the package:
	@#cp $(COLLECTD_DIR)/profile $(COLLECTD_TARGET_DIR)/root/usr/lib/collectd/profile
	@#cp $(COLLECTD_DIR)/menu $(COLLECTD_TARGET_DIR)/root/usr/lib/collectd/menu

$(PACKAGES_DIR)/.collectd-$(COLLECTD_VERSION): $(DL_DIR)/$(COLLECTD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(COLLECTD_PKG_SOURCE)
	@touch $@

collectd: $(PACKAGES_DIR)/.collectd-$(COLLECTD_VERSION)

collectd-package: $(PACKAGES_DIR)/.collectd-$(COLLECTD_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(COLLECTD_PKG_SOURCE) collectd-$(COLLECTD_VERSION)

collectd-precompiled: uclibc ncurses-precompiled collectd $(COLLECTD_TARGET_BINARY)

collectd-source: $(COLLECTD_DIR)/.unpacked $(PACKAGES_DIR)/.collectd-$(COLLECTD_VERSION)

collectd-clean:
	-$(MAKE) -C $(COLLECTD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(COLLECTD_PKG_SOURCE)

collectd-dirclean:
	rm -rf $(COLLECTD_DIR)
	rm -rf $(PACKAGES_DIR)/collectd-$(COLLECTD_VERSION)
	rm -f $(PACKAGES_DIR)/.collectd-$(COLLECTD_VERSION)

collectd-uninstall:
	rm -f $(COLLECTD_TARGET_BINARY)

collectd-list:
ifeq ($(strip $(DS_PACKAGE_COLLECTD)),y)
	@echo "S99collectd-$(COLLECTD_VERSION)" >> .static
else
	@echo "S99collectd-$(COLLECTD_VERSION)" >> .dynamic
endif
