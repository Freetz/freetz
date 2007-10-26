PACKAGE_LC:=ldd
PACKAGE_UC:=LDD
LDD_VERSION:=0.1
LDD_SOURCE:=ldd-$(LDD_VERSION).tar.bz2
LDD_SITE:=http://dsmod.magenbrot.net
LDD_DIR:=$(SOURCE_DIR)/ldd-$(LDD_VERSION)
LDD_SOURCE_FILE:=$(LDD_DIR)/ldd.c
LDD_BINARY:=$(LDD_DIR)/ldd
LDD_PKG_VERSION:=0.1
LDD_TARGET_DIR:=$(PACKAGES_DIR)/ldd-$(LDD_VERSION)
LDD_TARGET_BINARY:=$(LDD_TARGET_DIR)/root/usr/bin/ldd

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$(LDD_BINARY): $(LDD_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	    $(TARGET_CC) \
	    $(TARGET_CFLAGS) \
	    -DUCLIBC_RUNTIME_PREFIX=\ \
	    $(LDD_SOURCE_FILE) -o $@ 

$(LDD_TARGET_BINARY): $(LDD_BINARY)
	mkdir -p $(dir $(LDD_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

ldd:

ldd-precompiled: uclibc ldd $(LDD_TARGET_BINARY)

ldd-source: $(LDD_DIR)/.unpacked

ldd-clean:
	-$(MAKE) -C $(LDD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(LDD_PKG_SOURCE)

ldd-dirclean:
	rm -rf $(LDD_DIR)
		rm -rf $(PACKAGES_DIR)/$(LDD_PKG_NAME)

ldd-uninstall:
	rm -f $(LDD_TARGET_BINARY)