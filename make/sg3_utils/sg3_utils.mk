PACKAGE_LC:=sg3_utils
PACKAGE_UC:=SG3UTILS
$(PACKAGE_UC)_VERSION:=1.24
$(PACKAGE_INIT_BIN)
SG3UTILS_SOURCE:=sg3_utils-$(SG3UTILS_VERSION).tgz
SG3UTILS_SITE:=http://sg.torque.net/sg/p/
SG3UTILS_BINARY:=$(SG3UTILS_DIR)/sg_start
SG3UTILS_TARGET_BINARY:=$(SG3UTILS_DEST_DIR)/usr/bin/sg_start

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		CFLAGS="-DSG3_UTILS_LINUX $(TARGET_CFLAGS)" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		$(MAKE) -f no_lib/Makefile.linux sg_start -C $(SG3UTILS_DIR)
	touch $@

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

sg3_utils:

sg3_utils-precompiled: uclibc sg3_utils $($(PACKAGE_UC)_TARGET_BINARY)

sg3_utils-clean:
	-$(MAKE) -C $(SG3UTILS_DIR) clean
	rm -f $(SG3UTILS_DIR)/.installed
	rm -f $(SG3UTILS_DIR)/.built
	rm -f $(SG3UTILS_DIR)/.configured
	rm -f $(PACKAGES_BUILD_DIR)/$(SG3UTILS_PKG_SOURCE)

sg3_utils-uninstall:
	rm -f $(SG3UTILS_TARGET_BINARY)

$(PACKAGE_FINI)

