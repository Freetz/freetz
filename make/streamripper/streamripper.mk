STREAMRIPPER_VERSION:=1.61.27
STREAMRIPPER_SOURCE:=streamripper-$(STREAMRIPPER_VERSION).tar.gz
STREAMRIPPER_SITE:=http://mesh.dl.sourceforge.net/sourceforge/streamripper
STREAMRIPPER_DIR:=$(SOURCE_DIR)/streamripper-$(STREAMRIPPER_VERSION)
STREAMRIPPER_MAKE_DIR:=$(MAKE_DIR)/streamripper
STREAMRIPPER_TARGET_DIR:=$(PACKAGES_DIR)/streamripper-$(STREAMRIPPER_VERSION)/root/usr/bin
STREAMRIPPER_TARGET_BINARY:=streamripper
STREAMRIPPER_PKG_VERSION:=0.1
#STREAMRIPPER_PKG_SOURCE:=streamripper-$(STREAMRIPPER_VERSION)-dsmod-$(STREAMRIPPER_PKG_VERSION).tar.bz2
#STREAMRIPPER_PKG_SITE:=http://www.eiband.info/dsmod
STREAMRIPPER_PKG_SOURCE:=streamripper-$(STREAMRIPPER_VERSION)-dsmod-binary-only.tar.bz2
#STREAMRIPPER_PKG_SITE:=http://www.eiband.info/dsmod/testing


$(DL_DIR)/$(STREAMRIPPER_SOURCE):
	wget -P $(DL_DIR) $(STREAMRIPPER_SITE)/$(STREAMRIPPER_SOURCE)

$(DL_DIR)/$(STREAMRIPPER_PKG_SOURCE):
	@wget -P $(DL_DIR) $(STREAMRIPPER_PKG_SITE)/$(STREAMRIPPER_PKG_SOURCE)

$(STREAMRIPPER_DIR)/.unpacked: $(DL_DIR)/$(STREAMRIPPER_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(STREAMRIPPER_SOURCE)
	for i in $(STREAMRIPPER_MAKE_DIR)/patches/*.patch; do \
		patch -d $(STREAMRIPPER_DIR) -p1 < $$i; \
	done
	touch $@

$(STREAMRIPPER_DIR)/.configured: mad $(STREAMRIPPER_DIR)/.unpacked
	( cd $(STREAMRIPPER_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
		./configure \
		--target="$(GNU_TARGET_NAME)" \
		--host="$(GNU_TARGET_NAME)" \
		--build="$(GNU_HOST_NAME)" \
		--prefix=/usr \
		--without-ogg \
		--without-vorbis \
	);
	touch $@

$(STREAMRIPPER_DIR)/$(STREAMRIPPER_TARGET_BINARY): $(STREAMRIPPER_DIR)/.configured
	( PATH="$(TARGET_PATH)" \
		make -C $(STREAMRIPPER_DIR) all\
	);

$(PACKAGES_DIR)/.streamripper-$(STREAMRIPPER_VERSION): $(DL_DIR)/$(STREAMRIPPER_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(STREAMRIPPER_PKG_SOURCE)
	@touch $@

streamripper: $(PACKAGES_DIR)/.streamripper-$(STREAMRIPPER_VERSION)

streamripper-package: $(PACKAGES_DIR)/.streamripper-$(STREAMRIPPER_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(STREAMRIPPER_PKG_SOURCE) streamripper-$(STREAMRIPPER_VERSION)

streamripper-precompiled: $(STREAMRIPPER_DIR)/$(STREAMRIPPER_TARGET_BINARY) streamripper
	$(TARGET_STRIP) $(STREAMRIPPER_DIR)/$(STREAMRIPPER_TARGET_BINARY)
	cp $(STREAMRIPPER_DIR)/$(STREAMRIPPER_TARGET_BINARY) $(STREAMRIPPER_TARGET_DIR)/

streamripper-source: $(STREAMRIPPER_DIR)/.unpacked $(PACKAGES_DIR)/.streamripper-$(STREAMRIPPER_VERSION)

streamripper-clean:
	-$(MAKE) -C $(STREAMRIPPER_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(STREAMRIPPER_PKG_SOURCE)

streamripper-dirclean:
	rm -rf $(STREAMRIPPER_DIR)
	rm -rf $(PACKAGES_DIR)/streamripper-$(STREAMRIPPER_VERSION)
	rm -f $(PACKAGES_DIR)/.streamripper-$(STREAMRIPPER_VERSION)

streamripper-list:
ifeq ($(strip $(DS_PACKAGE_STREAMRIPPER)),y)
	@echo "S40streamripper-$(STREAMRIPPER_VERSION)" >> .static
else
	@echo "S40streamripper-$(STREAMRIPPER_VERSION)" >> .dynamic
endif
