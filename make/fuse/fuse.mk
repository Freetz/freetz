$(call PKG_INIT_BIN, 2.9.9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d0e69d5d608cc22ff4843791ad097f554dd32540ddc9bed7638cc6fea7c1b4b5
$(PKG)_SITE:=https://github.com/libfuse/libfuse/releases/download/fuse-$($(PKG)_VERSION)
### WEBSITE:=https://github.com/libfuse/libfuse
### MANPAGE:=https://github.com/libfuse/libfuse/wiki
### CHANGES:=https://github.com/libfuse/libfuse/releases
### CVSREPO:=https://github.com/libfuse/libfuse/commits/master

$(PKG)_PATCH_POST_CMDS += $(SED) -i -r -e 's| -D_FILE_OFFSET_BITS=64||g;' fuse.pc.in {example,lib,util}/Makefile.{am,in};

$(PKG)_BINARY:=$($(PKG)_DIR)/util/fusermount
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/fusermount

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libfuse.so.$($(PKG)_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so.$($(PKG)_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libfuse.so.$($(PKG)_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-lib
$(PKG)_CONFIGURE_OPTIONS += --enable-util
$(PKG)_CONFIGURE_OPTIONS += --disable-mtab
$(PKG)_CONFIGURE_OPTIONS += --disable-example
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FUSE_DIR) \
		V=1 \
		all

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	cp $(FUSE_DIR)/fuse.pc $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fuse.pc
	$(SUBMAKE) -C $(FUSE_DIR)/lib \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libulockmgr.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fuse.pc
	$(SUBMAKE) -C $(FUSE_DIR)/include \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)


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
		$(FUSE_TARGET_LIBDIR)/libfuse*.so*

$(call PKG_ADD_LIB,libfuse)
$(PKG_FINISH)
