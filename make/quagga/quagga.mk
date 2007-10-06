QUAGGA_VERSION:=0.99.6
QUAGGA_SOURCE:=quagga-$(QUAGGA_VERSION).tar.gz
QUAGGA_SITE:=http://www.quagga.net/download
QUAGGA_DIR:=$(SOURCE_DIR)/quagga-$(QUAGGA_VERSION)
QUAGGA_MAKE_DIR:=$(MAKE_DIR)/quagga
QUAGGA_BINARY:=$(QUAGGA_DIR)/zebra/.libs/zebra
QUAGGA_PKG_VERSION:=0.1
QUAGGA_PKG_SITE:=http://www.heimpold.de/dsmod
QUAGGA_PKG_NAME:=quagga-$(QUAGGA_VERSION)
QUAGGA_PKG_SOURCE:=quagga-$(QUAGGA_VERSION)-dsmod-$(QUAGGA_PKG_VERSION).tar.bz2
QUAGGA_TARGET_DIR:=$(PACKAGES_DIR)/$(QUAGGA_PKG_NAME)/root
QUAGGA_TARGET_BINARY:=$(QUAGGA_TARGET_DIR)/usr/sbin/zebra
QUAGGA_TARGET_LIBDIR:=$(QUAGGA_TARGET_DIR)/usr/lib

QUAGGA_CONFIGURE_OPTIONS=\
  --enable-user=root \
  --enable-group=root \
  --enable-shared \
  --disable-static \
  --enable-multipath=8 \
  --enable-vtysh \
  --with-gnu-ld \
  --disable-capabilities \
  $(if $(DS_PACKAGE_QUAGGA_BGPD),--enable-bgpd,--disable-bgpd) \
  $(if $(DS_PACKAGE_QUAGGA_RIPD),--enable-ripd,--disable-ripd) \
  $(if $(DS_PACKAGE_QUAGGA_RIPNGD),--enable-ripngd,--disable-ripngd) \
  $(if $(DS_PACKAGE_QUAGGA_OSPFD),--enable-ospfd,--disable-ospfd) \
  $(if $(DS_PACKAGE_QUAGGA_OSPF6D),--enable-ospf6d,--disable-ospf6d) \
  $(if $(DS_PACKAGE_QUAGGA_ISISD),--enable-isisd,--disable-isisd)

QUAGGA_DAEMONS:=zebra \
		$(if $(DS_PACKAGE_QUAGGA_BGPD),bgpd,) \
		$(if $(DS_PACKAGE_QUAGGA_RIPD),ripd,) \
		$(if $(DS_PACKAGE_QUAGGA_RIPNGD),ripngd,) \
		$(if $(DS_PACKAGE_QUAGGA_OSPFD),ospfd,) \
	        $(if $(DS_PACKAGE_QUAGGA_OSPF6D),ospf6d,) \
		$(if $(DS_PACKAGE_QUAGGA_ISISD),isisd,)

QUAGGA_DS_CONFIG_FILE:=$(QUAGGA_MAKE_DIR)/.ds_config
QUAGGA_DS_CONFIG_TEMP:=$(QUAGGA_MAKE_DIR)/.ds_config.temp

$(DL_DIR)/$(QUAGGA_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(QUAGGA_SITE)/$(QUAGGA_SOURCE)

$(DL_DIR)/$(QUAGGA_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(QUAGGA_PKG_SOURCE) $(QUAGGA_PKG_SITE)

$(QUAGGA_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_PACKAGE_QUAGGA_BGPD=$(if $(DS_PACKAGE_QUAGGA_BGPD),y,n)" > $(QUAGGA_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_QUAGGA_RIPD=$(if $(DS_PACKAGE_QUAGGA_RIPD),y,n)" >> $(QUAGGA_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_QUAGGA_RIPNGD=$(if $(DS_PACKAGE_QUAGGA_RIPNGD),y,n)" >> $(QUAGGA_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_QUAGGA_OSPFD=$(if $(DS_PACKAGE_QUAGGA_OSPFD),y,n)" >> $(QUAGGA_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_QUAGGA_OSPF6D=$(if $(DS_PACKAGE_QUAGGA_OSPF6D),y,n)" >> $(QUAGGA_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_QUAGGA_ISISD=$(if $(DS_PACKAGE_QUAGGA_ISISD),y,n)" >> $(QUAGGA_DS_CONFIG_TEMP)
	@diff -q $(QUAGGA_DS_CONFIG_TEMP) $(QUAGGA_DS_CONFIG_FILE) || \
	    cp $(QUAGGA_DS_CONFIG_TEMP) $(QUAGGA_DS_CONFIG_FILE)
	@rm -f $(QUAGGA_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(QUAGGA_DIR)/.unpacked: $(DL_DIR)/$(QUAGGA_SOURCE) $(QUAGGA_DS_CONFIG_FILE)
	rm -rf $(QUAGGA_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(QUAGGA_SOURCE)
	for i in $(QUAGGA_MAKE_DIR)/patches/*.patch; do \
	    $(PATCH_TOOL) $(QUAGGA_DIR) $$i; \
	done
	touch $@

$(QUAGGA_DIR)/.configured: $(QUAGGA_DIR)/.unpacked
	( cd $(QUAGGA_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
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
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--datadir=/usr/share \
		--sysconfdir=/etc/quagga \
		--localstatedir=/var/run/quagga \
		--libdir=/usr/lib \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--mandir=/usr/share/man \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		$(QUAGGA_CONFIGURE_OPTIONS) \
	);
	touch $@

$(QUAGGA_BINARY): $(QUAGGA_DIR)/.configured
	PATH="$(TARGET_PATH)" LD="$(TARGET_LD)" $(MAKE) -C $(QUAGGA_DIR)

$(QUAGGA_TARGET_BINARY): $(QUAGGA_BINARY)
	# copy, strip and chmod base libs
	cp -d $(QUAGGA_DIR)/lib/.libs/lib*.so* $(QUAGGA_TARGET_LIBDIR)
	$(TARGET_STRIP) $(QUAGGA_TARGET_LIBDIR)/lib*.so*
	chmod -x $(QUAGGA_TARGET_LIBDIR)/lib*.so*
	# vtysh
	cp $(QUAGGA_DIR)/vtysh/.libs/vtysh $(QUAGGA_TARGET_DIR)/usr/bin
	$(TARGET_STRIP) $(QUAGGA_TARGET_DIR)/usr/bin/vtysh
	# install routing routing daemons and libs
	for d in $(QUAGGA_DAEMONS); do \
		if [ -f $(QUAGGA_DIR)/$$d/.libs/$$d ]; then \
			cp $(QUAGGA_DIR)/$$d/.libs/$$d $(QUAGGA_TARGET_DIR)/usr/sbin; \
			$(TARGET_STRIP) $(QUAGGA_TARGET_DIR)/usr/sbin/$$d; \
		fi; \
		(shopt -s nullglob; for f in $(QUAGGA_DIR)/$$d/.libs/lib*.so*; do \
			cp -d $$f $(QUAGGA_TARGET_LIBDIR); \
		done;) \
	done
	# install supervisor daemon
	$(INSTALL_BINARY_STRIP)

quagga-uninstall:
	rm -f $(QUAGGA_TARGET_LIBDIR)/lib*.so*	
	rm -f $(QUAGGA_TARGET_DIR)/usr/sbin/*
	rm -f $(QUAGGA_TARGET_DIR)/usr/bin/vtysh

$(PACKAGES_DIR)/.$(QUAGGA_PKG_NAME): $(DL_DIR)/$(QUAGGA_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(QUAGGA_PKG_SOURCE)
	@touch $@

quagga: $(PACKAGES_DIR)/.$(QUAGGA_PKG_NAME)

quagga-package: $(PACKAGES_DIR)/.$(QUAGGA_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(QUAGGA_PKG_SOURCE) $(QUAGGA_PKG_NAME)

quagga-precompiled: uclibc ncurses-precompiled readline-precompiled quagga $(QUAGGA_TARGET_BINARY)

quagga-source: $(QUAGGA_DIR)/.unpacked $(PACKAGES_DIR)/.$(QUAGGA_PKG_NAME)

quagga-clean:
	-$(MAKE) -C $(QUAGGA_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(QUAGGA_PKG_SOURCE)
	rm -f $(QUAGGA_DIR)/.configured
	rm -f $(QUAGGA_DS_CONFIG_FILE)

quagga-dirclean:
	rm -rf $(QUAGGA_DIR)
	rm -rf $(PACKAGES_DIR)/$(QUAGGA_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(QUAGGA_PKG_NAME)
	rm -f $(QUAGGA_DS_CONFIG_FILE)

quagga-list:
ifeq ($(strip $(DS_PACKAGE_QUAGGA)),y)
	@echo "S80quagga-$(QUAGGA_VERSION)" >> .static
else
	@echo "S80quagga-$(QUAGGA_VERSION)" >> .dynamic
endif
