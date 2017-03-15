$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_FUSE_VERSION_2_7),2.7.6,2.9.7))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5_2.7.6:=319f12dffd6f7073628fefc980254f4a
$(PKG)_SOURCE_MD5_2.9.7:=9bd4ce8184745fd3d000ca2692adacdb
$(PKG)_SOURCE_MD5:=$($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))
# don't get confused by 2_9_4 - it's a subdir containing 2.9.4 and all older fuse versions (s. https://github.com/libfuse/libfuse/releases)
$(PKG)_SITE:=https://github.com/libfuse/libfuse/releases/download/fuse-$($(PKG)_VERSION),https://github.com/libfuse/libfuse/releases/download/fuse_2_9_4

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_PATCH_POST_CMDS += $(SED) -i -r -e 's| -D_FILE_OFFSET_BITS=64||g;' fuse.pc.in {example,lib,util}/Makefile.{am,in};

$(PKG)_BUILD_KERNEL_MODULE:=$(strip $(FREETZ_KERNEL_VERSION_2_6_13))

$(PKG)_BINARY:=$($(PKG)_DIR)/util/fusermount
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/fusermount

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libfuse.so.$($(PKG)_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so.$($(PKG)_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libfuse.so.$($(PKG)_VERSION)

$(PKG)_DEPENDS_ON += kernel

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_LAYOUT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FUSE_VERSION_2_7
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FUSE_VERSION_2_9

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-lib
$(PKG)_CONFIGURE_OPTIONS += --enable-util
$(PKG)_CONFIGURE_OPTIONS += --disable-example
$(PKG)_CONFIGURE_OPTIONS += --disable-mtab
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld
$(PKG)_CONFIGURE_OPTIONS += --with-kernel="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)"

ifeq ($($(PKG)_BUILD_KERNEL_MODULE),y)
$(PKG)_MOD_BINARY:=$($(PKG)_DIR)/kernel/fuse.ko
$(PKG)_MOD_TARGET_DIR:=$(KERNEL_MODULES_DIR)/fs/fuse
$(PKG)_MOD_TARGET_BINARY:=$($(PKG)_MOD_TARGET_DIR)/fuse.ko
$(PKG)_CONFIGURE_OPTIONS += --enable-kernel-module
$(PKG)_CONFIGURE_OPTIONS += --disable-auto-modprobe
else
$(PKG)_CONFIGURE_OPTIONS += --disable-kernel-module
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY) $(if $($(PKG)_BUILD_KERNEL_MODULE),$($(PKG)_MOD_BINARY)): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FUSE_DIR) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		V=1 \
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

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

ifeq ($($(PKG)_BUILD_KERNEL_MODULE),y)
$($(PKG)_MOD_TARGET_BINARY): $($(PKG)_MOD_BINARY)
	$(INSTALL_FILE)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY) \
		$(if $($(PKG)_BUILD_KERNEL_MODULE),$($(PKG)_MOD_TARGET_BINARY))

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
		$(FUSE_TARGET_LIBDIR)/libfuse*.so* \
		$(if $(FUSE_BUILD_KERNEL_MODULE),$(FUSE_MOD_TARGET_BINARY))

$(call PKG_ADD_LIB,libfuse)
$(PKG_FINISH)
