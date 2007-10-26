PACKAGE_LC:=ntfs
PACKAGE_UC:=NTFS
NTFS_VERSION:=1.1004
NTFS_SOURCE:=ntfs-3g-$(NTFS_VERSION).tgz
NTFS_SITE:=http://www.ntfs-3g.org/
NTFS_MAKE_DIR:=$(MAKE_DIR)/ntfs
NTFS_DIR:=$(SOURCE_DIR)/ntfs-3g-$(NTFS_VERSION)
NTFS_BINARY:=$(NTFS_DIR)/src/ntfs-3g
NTFS_TARGET_DIR:=$(PACKAGES_DIR)/ntfs-$(NTFS_VERSION)
NTFS_TARGET_BINARY:=$(NTFS_TARGET_DIR)/root/usr/bin/ntfs-3g
NTFS_STARTLEVEL=30

$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += touch configure.in aclocal.m4 Makefile.in include/config.h.in configure ;
$(PACKAGE_UC)_CONFIGURE_ENV += FUSE_MODULE_CFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include/fuse"
$(PACKAGE_UC)_CONFIGURE_ENV += FUSE_MODULE_LIBS="-pthread -lfuse -ldl"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-rpath
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-kernel-module
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-lib
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-util
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-example
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-auto-modprobe
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-kernel="$(shell pwd)/../$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-mtab


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$(NTFS_BINARY): $(NTFS_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		-C $(NTFS_DIR) all

$(NTFS_TARGET_BINARY): $(NTFS_BINARY)
	mkdir -p $(dir $(NTFS_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.ntfs-$(NTFS_VERSION):
	mkdir -p $(NTFS_TARGET_DIR)/root
	tar -c -C $(NTFS_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(NTFS_TARGET_DIR)
	touch $@

ntfs: uclibc fuse $(PACKAGES_DIR)/.ntfs-$(NTFS_VERSION) \
	$(NTFS_TARGET_BINARY)

ntfs-precompiled: fuse-precompiled ntfs $(NTFS_TARGET_BINARY)

ntfs-source: $(NTFS_DIR)/.unpacked

ntfs-clean:
	-$(MAKE) -C $(NTFS_DIR) clean

ntfs-dirclean:
	rm -rf $(NTFS_DIR)
	rm -rf $(PACKAGES_DIR)/ntfs-$(NTFS_VERSION)
	rm -f $(PACKAGES_DIR)/.ntfs-$(NTFS_VERSION)

ntfs-uninstall:
	rm -f $(NTFS_TARGET_BINARY)

$(PACKAGE_LIST)
