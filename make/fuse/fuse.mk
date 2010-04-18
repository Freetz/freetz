$(call PKG_INIT_BIN, 2.7.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b428c526d86cf004cca0f8c83270445b
$(PKG)_SITE:=@SF/fuse

$(PKG)_BINARY:=$($(PKG)_DIR)/util/fusermount
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/fusermount
$(PKG)_MOD_BINARY:=$($(PKG)_DIR)/kernel/fuse.ko
$(PKG)_MOD_TARGET_DIR:=$(KERNEL_MODULES_DIR)/fs/fuse
$(PKG)_MOD_TARGET_BINARY:=$($(PKG)_MOD_TARGET_DIR)/fuse.ko
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libfuse.so.$($(PKG)_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so.$($(PKG)_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libfuse.so.$($(PKG)_VERSION)

$(PKG)_DEPENDS_ON := kernel

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_LAYOUT

$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's|-D_FILE_OFFSET_BITS=64||g;' fuse.pc.in {example,lib,util}/Makefile.{am,in};
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's|^([ \t]*\#error .*-D_FILE_OFFSET_BITS=64.*)$$$$|/*\1*/|g;' include/fuse_common.h;

$(PKG)_CONFIGURE_ENV += acl_cv_libext=a

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-kernel-module
$(PKG)_CONFIGURE_OPTIONS += --enable-lib
$(PKG)_CONFIGURE_OPTIONS += --enable-util
$(PKG)_CONFIGURE_OPTIONS += --disable-example
$(PKG)_CONFIGURE_OPTIONS += --disable-auto-modprobe
$(PKG)_CONFIGURE_OPTIONS += --with-kernel="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --disable-mtab
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_MOD_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FUSE_DIR) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		all

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	cp $(FUSE_DIR)/fuse.pc $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fuse.pc
	$(SUBMAKE) -C $(FUSE_DIR)/lib \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libulockmgr.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fuse.pc
	$(SUBMAKE) -C $(FUSE_DIR)/include \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MOD_TARGET_BINARY): $($(PKG)_MOD_BINARY)
	$(INSTALL_FILE)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_MOD_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FUSE_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/fuse.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ulockmgr.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fuse* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libulockmgr*

$(pkg)-uninstall:
	$(RM) \
		$(FUSE_TARGET_BINARY) \
		$(FUSE_MOD_TARGET_BINARY) \
		$(FUSE_TARGET_LIBDIR)/libfuse*.so*

$(PKG_FINISH)
