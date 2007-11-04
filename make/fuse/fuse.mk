$(call PKG_INIT_BIN, 2.7.1)
$(PKG)_SOURCE:=fuse-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/fuse
$(PKG)_BINARY:=$($(PKG)_DIR)/util/fusermount
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/fusermount
$(PKG)_MOD_BINARY:=$($(PKG)_DIR)/kernel/fuse.ko
$(PKG)_MOD_TARGET_DIR:=$(KERNEL_MODULES_DIR)/lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/kernel/fs/fuse
$(PKG)_MOD_TARGET_BINARY:=$($(PKG)_MOD_TARGET_DIR)/fuse.ko
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libfuse.so.$($(PKG)_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so.$($(PKG)_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/libfuse.so.$($(PKG)_VERSION)

$(PKG)_DS_CONFIG_FILE:=$($(PKG)_MAKE_DIR)/.ds_config
$(PKG)_DS_CONFIG_TEMP:=$($(PKG)_MAKE_DIR)/.ds_config.temp

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-kernel-module
$(PKG)_CONFIGURE_OPTIONS += --enable-lib
$(PKG)_CONFIGURE_OPTIONS += --enable-util
$(PKG)_CONFIGURE_OPTIONS += --disable-example
$(PKG)_CONFIGURE_OPTIONS += --disable-auto-modprobe
$(PKG)_CONFIGURE_OPTIONS += --with-kernel="$(DSMOD_BASE_DIR)/$(KERNEL_SOURCE_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --disable-mtab
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld


$(PKG_SOURCE_DOWNLOAD)

$($(PKG)_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_KERNEL_LAYOUT=$(DS_KERNEL_LAYOUT)" > $(FUSE_DS_CONFIG_TEMP)
	@diff -q $(FUSE_DS_CONFIG_TEMP) $(FUSE_DS_CONFIG_FILE) || \
	    cp $(FUSE_DS_CONFIG_TEMP) $(FUSE_DS_CONFIG_FILE)
	@rm -f $(FUSE_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) $($(PKG)_DS_CONFIG_FILE)
	rm -rf $(FUSE_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FUSE_SOURCE)
	for i in $(FUSE_MAKE_DIR)/patches/*.patch; do \
	$(PATCH_TOOL) $(FUSE_DIR) $$i; \
	done
	touch $@

$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_MOD_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) \
		$(MAKE) -C $(FUSE_DIR) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		all

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	cp $(FUSE_DIR)/fuse.pc $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/fuse.pc
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) $(MAKE) \
		-C $(FUSE_DIR)/lib \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libfuse.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libulockmgr.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/fuse.pc
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) $(MAKE) \
		-C $(FUSE_DIR)/include \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MOD_TARGET_BINARY): $($(PKG)_MOD_BINARY)
	mkdir -p $(dir $@)
	cp $^ $@

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so* $(FUSE_TARGET_DIR)/root/usr/lib
	$(TARGET_STRIP) $@

fuse:

fuse-precompiled: uclibc fuse $($(PKG)_TARGET_BINARY) $($(PKG)_MOD_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

fuse-clean:
	-$(MAKE) -C $(FUSE_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/fuse.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ulockmgr.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fuse* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*

fuse-uninstall:
	rm -f $(FUSE_TARGET_BINARY)
	rm -f $(FUSE_MOD_TARGET_BINARY)
	rm -f $(FUSE_TARGET_DIR)/root/usr/lib/libfuse*.so*

$(PKG_FINISH)
