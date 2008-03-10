COLLECTD_VERSION:=4.0.7
COLLECTD_SOURCE:=collectd-$(COLLECTD_VERSION).tar.gz
COLLECTD_SITE:=http://collectd.org/files
COLLECTD_MAKE_DIR:=$(MAKE_DIR)/collectd
COLLECTD_DIR:=$(SOURCE_DIR)/collectd-$(COLLECTD_VERSION)
COLLECTD_BINARY:=$(COLLECTD_DIR)/src/collectd
COLLECTD_TARGET_DIR:=$(PACKAGES_DIR)/collectd-$(COLLECTD_VERSION)
COLLECTD_TARGET_BINARY:=$(COLLECTD_TARGET_DIR)/root/usr/bin/collectd
COLLECTD_PKG_VERSION:=0.1
COLLECTD_PKG_SOURCE:=collectd-$(COLLECTD_VERSION)-dsmod-$(COLLECTD_PKG_VERSION).tar.bz2
COLLECTD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

$(DL_DIR)/$(COLLECTD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(COLLECTD_SITE)/$(COLLECTD_SOURCE)

$(DL_DIR)/$(COLLECTD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(COLLECTD_PKG_SOURCE) $(COLLECTD_PKG_SITE)

$(COLLECTD_DIR)/.unpacked: $(DL_DIR)/$(COLLECTD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(COLLECTD_SOURCE)
#	for i in $(COLLECTD_MAKE_DIR)/patches/*.patch; do \
#		$(PATCH_TOOL) $(COLLECTD_DIR) $$i; \
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
		--disable-apache \
		--disable-apcups \
		--disable-apple_sensors \
		--disable-battery \
		--disable-cpu \
		--disable-cpufreq \
		--disable-disk \
		--disable-csv \
		--disable-df \
		--disable-dns \
		--disable-email \
		--disable-entropy \
		--disable-exec \
		--disable-hddtemp \
		--disable-interface \
		--disable-iptables \
		--disable-irq \
		--disable-load \
		--disable-mbmon \
		--disable-memory \
		--disable-multimeter \
		--disable-mysql \
		--disable-network \
		--disable-nfs \
		--disable-ntpd \
		--disable-nut \
		--disable-perl \
		--disable-ping \
		--disable-processes \
		--disable-sensors \
		--disable-serial \
		--disable-logfile \
		--disable-swap \
		--disable-syslog \
		--disable-tape \
		--disable-unixsock \
		--disable-users \
		--disable-vserver \
		--disable-wireless \
		--with-nan-emulation \
	);
	touch $@

$(COLLECTD_BINARY): $(COLLECTD_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) AM_CFLAGS="" -C $(COLLECTD_DIR)

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
ifeq ($(strip $(FREETZ_PACKAGE_COLLECTD)),y)
	@echo "S99collectd-$(COLLECTD_VERSION)" >> .static
else
	@echo "S99collectd-$(COLLECTD_VERSION)" >> .dynamic
endif
