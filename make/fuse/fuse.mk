PACKAGE_LC:=fuse
PACKAGE_UC:=FUSE
FUSE_VERSION:=2.7.0
FUSE_SOURCE:=fuse-$(FUSE_VERSION).tar.gz
FUSE_SITE:=http://mesh.dl.sourceforge.net/sourceforge/fuse
FUSE_MAKE_DIR:=$(MAKE_DIR)/fuse
FUSE_PKG_NAME:=fuse-$(FUSE_VERSION)
FUSE_PKG_VERSION:=0.1
FUSE_DIR:=$(SOURCE_DIR)/fuse-$(FUSE_VERSION)
FUSE_BINARY:=$(FUSE_DIR)/util/fusermount
FUSE_TARGET_DIR:=$(PACKAGES_DIR)/$(FUSE_PKG_NAME)
FUSE_TARGET_BINARY:=$(FUSE_TARGET_DIR)/root/usr/sbin/fusermount
FUSE_MOD_BINARY:=$(FUSE_DIR)/kernel/fuse.ko
FUSE_MOD_TARGET_DIR:=$(KERNEL_MODULES_DIR)/lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/kernel/fs/fuse
FUSE_MOD_TARGET_BINARY:=$(FUSE_MOD_TARGET_DIR)/fuse.ko
FUSE_LIB_BINARY:=$(FUSE_DIR)/lib/.libs/libfuse.so.$(FUSE_VERSION)
FUSE_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so.$(FUSE_VERSION)
FUSE_LIB_TARGET_BINARY:=$(FUSE_TARGET_DIR)/root/usr/lib/libfuse.so.$(FUSE_VERSION)
FUSE_STARTLEVEL=40

FUSE_DS_CONFIG_FILE:=$(FUSE_MAKE_DIR)/.ds_config
FUSE_DS_CONFIG_TEMP:=$(FUSE_MAKE_DIR)/.ds_config.temp

$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += touch configure.in aclocal.m4 Makefile.in include/config.h.in configure ;
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-rpath
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-kernel-module
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-lib
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-util
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-example
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-auto-modprobe
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-kernel="$(shell pwd)/$(KERNEL_SOURCE_DIR)"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-mtab
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-gnu-ld


$(PACKAGE_SOURCE_DOWNLOAD)

$(FUSE_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_KERNEL_LAYOUT=$(DS_KERNEL_LAYOUT)" > $(FUSE_DS_CONFIG_TEMP)
	@diff -q $(FUSE_DS_CONFIG_TEMP) $(FUSE_DS_CONFIG_FILE) || \
	    cp $(FUSE_DS_CONFIG_TEMP) $(FUSE_DS_CONFIG_FILE)
	@rm -f $(FUSE_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(FUSE_DIR)/.unpacked: $(DL_DIR)/$(FUSE_SOURCE) $(FUSE_DS_CONFIG_FILE)
	rm -rf $(FUSE_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FUSE_SOURCE)
	for i in $(FUSE_MAKE_DIR)/patches/*.patch; do \
	$(PATCH_TOOL) $(FUSE_DIR) $$i; \
	done
	touch $@

$(PACKAGE_CONFIGURED_CONFIGURE)

$(FUSE_BINARY) $(FUSE_MOD_BINARY) $(FUSE_LIB_BINARY): $(FUSE_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) \
		$(MAKE) -C $(FUSE_DIR) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		all

$(FUSE_LIB_STAGING_BINARY): $(FUSE_LIB_BINARY)
	cp $(FUSE_DIR)/fuse.pc $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/fuse.pc
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) $(MAKE) \
		-C $(FUSE_DIR)/lib \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libfuse.la
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libulockmgr.la
	$(SED) -i -e "s,^includedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/fuse.pc
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/fuse.pc
	
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) $(MAKE) \
		-C $(FUSE_DIR)/include \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(FUSE_TARGET_BINARY): $(FUSE_BINARY)
	mkdir -p $(dir $(FUSE_TARGET_BINARY)
	$(INSTALL_BINARY_STRIP)

$(FUSE_MOD_TARGET_BINARY): $(FUSE_MOD_BINARY)
	mkdir -p $(FUSE_MOD_TARGET_DIR)
	cp $^ $@

$(FUSE_LIB_TARGET_BINARY): $(FUSE_LIB_STAGING_BINARY)
	mkdir -p $(FUSE_TARGET_DIR)/root/usr/lib
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so* $(FUSE_TARGET_DIR)/root/usr/lib
	$(TARGET_STRIP) $@

fuse:

fuse-precompiled: uclibc fuse $(FUSE_TARGET_BINARY) $(FUSE_MOD_TARGET_BINARY) $(FUSE_LIB_TARGET_BINARY)

fuse-source: $(FUSE_DIR)/.unpacked

fuse-clean:
	-$(MAKE) -C $(FUSE_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/fuse.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ulockmgr.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fuse* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*

fuse-dirclean:
	rm -rf $(FUSE_DIR)
	rm -rf $(PACKAGES_DIR)/$(FUSE_PKG_NAME)

fuse-uninstall:
	rm -f $(FUSE_TARGET_BINARY)
	rm -f $(FUSE_MOD_TARGET_BINARY)
	rm -f $(FUSE_TARGET_DIR)/root/usr/lib/libfuse*.so*
	
$(PACKAGE_LIST)
