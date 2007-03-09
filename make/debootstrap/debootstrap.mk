DEBOOTSTRAP_VERSION:=0.3.3.2
DEBOOTSTRAP_SOURCE:=debootstrap_$(DEBOOTSTRAP_VERSION).tar.gz
DEBOOTSTRAP_BINARY:=debootstrap-udeb_$(DEBOOTSTRAP_VERSION)_mipsel.udeb
DEBOOTSTRAP_SITE:=http://ftp.de.debian.org/debian/pool/main/d/debootstrap/
DEBOOTSTRAP_DIR:=$(SOURCE_DIR)/debootstrap-$(DEBOOTSTRAP_VERSION)
DEBOOTSTRAP_MAKE_DIR:=$(MAKE_DIR)/debootstrap
DEBOOTSTRAP_PKG_VERSION:=0.1
DEBOOTSTRAP_PKG_SITE:=http://www.heimpold.de/dsmod
DEBOOTSTRAP_PKG_NAME:=debootstrap-$(DEBOOTSTRAP_VERSION)
DEBOOTSTRAP_PKG_SOURCE:=debootstrap-$(DEBOOTSTRAP_VERSION)-dsmod-$(DEBOOTSTRAP_PKG_VERSION).tar.bz2
DEBOOTSTRAP_TARGET_ROOTDIR:=$(PACKAGES_DIR)/$(DEBOOTSTRAP_PKG_NAME)/root

$(DL_DIR)/$(DEBOOTSTRAP_SOURCE):
	wget -P $(DL_DIR) $(DEBOOTSTRAP_SITE)/$(DEBOOTSTRAP_SOURCE)

$(DL_DIR)/$(DEBOOTSTRAP_BINARY):
	wget -P $(DL_DIR) $(DEBOOTSTRAP_SITE)/$(DEBOOTSTRAP_BINARY)

$(DL_DIR)/$(DEBOOTSTRAP_PKG_SOURCE):
	@wget -P $(DL_DIR) $(DEBOOTSTRAP_PKG_SITE)/$(DEBOOTSTRAP_PKG_SOURCE)

$(DEBOOTSTRAP_DIR)/.unpacked: $(DL_DIR)/$(DEBOOTSTRAP_SOURCE) $(DL_DIR)/$(DEBOOTSTRAP_BINARY)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(DEBOOTSTRAP_SOURCE)
	( cd $(DEBOOTSTRAP_DIR); \
		ar -x ../../$(DL_DIR)/$(DEBOOTSTRAP_BINARY) data.tar.gz; \
		mkdir -p target; \
		cd target && tar xzf ../data.tar.gz && cd .. \
	);
	for i in $(DEBOOTSTRAP_MAKE_DIR)/patches/*.patch; do \
		patch -d $(DEBOOTSTRAP_DIR) -p1 < $$i; \
	done
	touch $@

$(DEBOOTSTRAP_DIR)/.configured: $(DEBOOTSTRAP_DIR)/.unpacked
	touch $@

$(DEBOOTSTRAP_DIR)/.built: $(DEBOOTSTRAP_DIR)/.configured
	cd $(DEBOOTSTRAP_DIR) && $(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CC) $(TARGET_CFLAGS) -static-libgcc -o pkgdetails pkgdetails.c
	touch $@

$(DEBOOTSTRAP_DIR)/.installed: $(DEBOOTSTRAP_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_STRIP) $(DEBOOTSTRAP_DIR)/pkgdetails
	cp -a $(DEBOOTSTRAP_DIR)/pkgdetails $(DEBOOTSTRAP_DIR)/target/usr/lib/debootstrap
	rm -f $(DEBOOTSTRAP_DIR)/target/usr/lib/debootstrap/scripts/breezy
	rm -f $(DEBOOTSTRAP_DIR)/target/usr/lib/debootstrap/scripts/hoary
	rm -f $(DEBOOTSTRAP_DIR)/target/usr/lib/debootstrap/scripts/warty
	rm -f $(DEBOOTSTRAP_DIR)/target/usr/lib/debootstrap/scripts/woody
	touch $@

$(PACKAGES_DIR)/.$(DEBOOTSTRAP_PKG_NAME): $(DL_DIR)/$(DEBOOTSTRAP_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(DEBOOTSTRAP_PKG_SOURCE)
	@touch $@

debootstrap: $(PACKAGES_DIR)/.$(DEBOOTSTRAP_PKG_NAME)

debootstrap-package: $(PACKAGES_DIR)/.$(DEBOOTSTRAP_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(DEBOOTSTRAP_PKG_SOURCE) $(DEBOOTSTRAP_PKG_NAME)

debootstrap-precompiled: $(DEBOOTSTRAP_DIR)/.installed debootstrap
	mkdir -p $(DEBOOTSTRAP_TARGET_ROOTDIR)
	cp -a $(DEBOOTSTRAP_DIR)/target/* $(DEBOOTSTRAP_TARGET_ROOTDIR)

debootstrap-source: $(DEBOOTSTRAP_DIR)/.unpacked $(PACKAGES_DIR)/.$(DEBOOTSTRAP_PKG_NAME)

debootstrap-clean:
	-$(MAKE) -C $(DEBOOTSTRAP_DIR) clean
	rm -f $(DEBOOTSTRAP_DIR)/.installed
	rm -f $(DEBOOTSTRAP_DIR)/.built
	rm -f $(DEBOOTSTRAP_DIR)/.configured
	rm -f $(PACKAGES_BUILD_DIR)/$(DEBOOTSTRAP_PKG_SOURCE)

debootstrap-dirclean:
	rm -rf $(DEBOOTSTRAP_DIR)
	rm -rf $(PACKAGES_DIR)/$(DEBOOTSTRAP_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(DEBOOTSTRAP_PKG_NAME)

debootstrap-list:
ifeq ($(strip $(DS_PACKAGE_DEBOOTSTRAP)),y)
	@echo "S99debootstrap-$(DEBOOTSTRAP_VERSION)" >> .static
else
	@echo "S99debootstrap-$(DEBOOTSTRAP_VERSION)" >> .dynamic
endif
