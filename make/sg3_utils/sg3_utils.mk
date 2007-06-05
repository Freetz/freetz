SG3UTILS_VERSION:=1.24
SG3UTILS_SOURCE:=sg3_utils-$(SG3UTILS_VERSION).tgz
SG3UTILS_SITE:=http://sg.torque.net/sg/p/
SG3UTILS_MAKE_DIR:=$(MAKE_DIR)/sg3_utils
SG3UTILS_DIR:=$(SOURCE_DIR)/sg3_utils-$(SG3UTILS_VERSION)
SG3UTILS_BINARY:=$(SG3UTILS_DIR)/sg_start
SG3UTILS_PKG_VERSION:=0.1
SG3UTILS_PKG_SITE:=http://www.heimpold.de/dsmod
SG3UTILS_PKG_NAME:=sg3_utils-$(SG3UTILS_VERSION)
SG3UTILS_PKG_SOURCE:=sg3_utils-$(SG3UTILS_VERSION)-dsmod-$(SG3UTILS_PKG_VERSION).tar.bz2
SG3UTILS_TARGET_DIR:=$(PACKAGES_DIR)/$(SG3UTILS_PKG_NAME)
SG3UTILS_TARGET_BINARY:=$(SG3UTILS_TARGET_DIR)/root/usr/bin/sg_start

$(DL_DIR)/$(SG3UTILS_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(SG3UTILS_SITE)/$(SG3UTILS_SOURCE)

$(DL_DIR)/$(SG3UTILS_PKG_SOURCE): | $(DL_DIR)
	@wget -P $(DL_DIR) $(SG3UTILS_PKG_SITE)/$(SG3UTILS_PKG_SOURCE)

$(SG3UTILS_DIR)/.unpacked: $(DL_DIR)/$(SG3UTILS_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(SG3UTILS_SOURCE)
	for i in $(SG3UTILS_MAKE_DIR)/patches/*.patch; do \
		patch -d $(SG3UTILS_DIR) -p0 < $$i; \
	done
	touch $@

$(SG3UTILS_BINARY): $(SG3UTILS_DIR)/.unpacked
	PATH="$(TARGET_PATH)" CFLAGS="$(TARGET_CFLAGS) $(CFLAGS_LARGEFILE)" \
		CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
		make -f no_lib/Makefile.linux sg_start -C $(SG3UTILS_DIR)
	touch $@

$(SG3UTILS_TARGET_BINARY): $(SG3UTILS_BINARY)
	$(TARGET_STRIP) $(SG3UTILS_BINARY)
	cp $(SG3UTILS_BINARY) $(SG3UTILS_TARGET_BINARY)

$(PACKAGES_DIR)/.$(SG3UTILS_PKG_NAME): $(DL_DIR)/$(SG3UTILS_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(SG3UTILS_PKG_SOURCE)
	@touch $@

sg3_utils: $(PACKAGES_DIR)/.$(SG3UTILS_PKG_NAME)

sg3_utils-package: $(PACKAGES_DIR)/.$(SG3UTILS_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(SG3UTILS_PKG_SOURCE) $(SG3UTILS_PKG_NAME)

sg3_utils-precompiled: uclibc sg3_utils $(SG3UTILS_TARGET_BINARY)

sg3_utils-source: $(SG3UTILS_DIR)/.unpacked $(PACKAGES_DIR)/.$(SG3UTILS_PKG_NAME)

sg3_utils-clean:
	-$(MAKE) -C $(SG3UTILS_DIR) clean
	rm -f $(SG3UTILS_DIR)/.installed
	rm -f $(SG3UTILS_DIR)/.built
	rm -f $(SG3UTILS_DIR)/.configured
	rm -f $(PACKAGES_BUILD_DIR)/$(SG3UTILS_PKG_SOURCE)

sg3_utils-dirclean:
	rm -rf $(SG3UTILS_DIR)
	rm -rf $(PACKAGES_DIR)/$(SG3UTILS_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(SG3UTILS_PKG_NAME)

sg3_utils-uninstall:
	rm -f $(SG3UTILS_TARGET_BINARY)

sg3_utils-list:
ifeq ($(strip $(DS_PACKAGE_SG3UTILS)),y)
	@echo "S90sg3_utils-$(SG3UTILS_VERSION)" >> .static
else
	@echo "S90sg3_utils-$(SG3UTILS_VERSION)" >> .dynamic
endif
