TRANSMISSION_VERSION:=0.5
TRANSMISSION_SOURCE:=Transmission-$(TRANSMISSION_VERSION).tar.gz
TRANSMISSION_SITE:=http://download.m0k.org/transmission/files
TRANSMISSION_DIR:=$(SOURCE_DIR)/Transmission-$(TRANSMISSION_VERSION)
TRANSMISSION_MAKE_DIR:=$(MAKE_DIR)/transmission
TRANSMISSION_TARGET_DIR:=$(PACKAGES_DIR)/transmission-$(TRANSMISSION_VERSION)/root/usr/bin
TRANSMISSION_TARGET_BINARY:=transmissioncli
TRANSMISSION_PKG_VERSION:=0.1
#TRANSMISSION_PKG_SOURCE:=transmission-$(TRANSMISSION_VERSION)-dsmod-$(TRANSMISSION_PKG_VERSION).tar.bz2
#TRANSMISSION_PKG_SITE:=http://www.eiband.info/dsmod
TRANSMISSION_PKG_SOURCE:=transmission-$(TRANSMISSION_VERSION)-dsmod-binary-only.tar.bz2
TRANSMISSION_PKG_SITE:=http://www.eiband.info/dsmod/testing


$(DL_DIR)/$(TRANSMISSION_SOURCE):
	wget -P $(DL_DIR) $(TRANSMISSION_SITE)/$(TRANSMISSION_SOURCE)

$(DL_DIR)/$(TRANSMISSION_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(TRANSMISSION_PKG_SOURCE) $(TRANSMISSION_PKG_SITE)

$(TRANSMISSION_DIR)/.unpacked: $(DL_DIR)/$(TRANSMISSION_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(TRANSMISSION_SOURCE)
	for i in $(TRANSMISSION_MAKE_DIR)/patches/*.patch; do \
		patch -d $(TRANSMISSION_DIR) -p0 < $$i; \
	done
	touch $@

$(TRANSMISSION_DIR)/.configured: $(TRANSMISSION_DIR)/.unpacked
	( cd $(TRANSMISSION_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
		./configure \
		--prefix=/usr \
		--disable-gtk \
	);
ifneq ($(strip $(DS_TARGET_LFS)),y)
	sed -i -e 's,_FILE_OFFSET_BITS=64 _LARGEFILE_SOURCE,,g' \
		$(TRANSMISSION_DIR)/config.jam
endif
	touch $@

$(TRANSMISSION_DIR)/$(TRANSMISSION_TARGET_BINARY): $(TRANSMISSION_DIR)/.configured
	( cd $(TRANSMISSION_DIR); \
		jam \
	);

$(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION): $(DL_DIR)/$(TRANSMISSION_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(TRANSMISSION_PKG_SOURCE)
	@touch $@

transmission: $(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION)

transmission-package: $(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(TRANSMISSION_PKG_SOURCE) transmission-$(TRANSMISSION_VERSION)

transmission-precompiled: $(TRANSMISSION_DIR)/$(TRANSMISSION_TARGET_BINARY) transmission
	$(TARGET_STRIP) $(TRANSMISSION_DIR)/$(TRANSMISSION_TARGET_BINARY)
	cp $(TRANSMISSION_DIR)/$(TRANSMISSION_TARGET_BINARY) $(TRANSMISSION_TARGET_DIR)/

transmission-source: $(TRANSMISSION_DIR)/.unpacked $(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION)

transmission-clean:
	-$(MAKE) -C $(TRANSMISSION_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(TRANSMISSION_PKG_SOURCE)

transmission-dirclean:
	rm -rf $(TRANSMISSION_DIR)
	rm -rf $(PACKAGES_DIR)/transmission-$(TRANSMISSION_VERSION)
	rm -f $(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION)

transmission-list:
ifeq ($(strip $(DS_PACKAGE_TRANSMISSION)),y)
	@echo "S40transmission-$(TRANSMISSION_VERSION)" >> .static
else
	@echo "S40transmission-$(TRANSMISSION_VERSION)" >> .dynamic
endif
