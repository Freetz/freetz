$(call PKG_INIT_LIB, 3.9.5)
$(PKG)_LIB_VERSION:=3.9.5
$(PKG)_SOURCE:=tiff-$($(PKG)_LIB_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=8fc7ce3b4e1d0cc8a319336967815084
$(PKG)_SITE:=ftp://ftp.remotesensing.org/pub/libtiff

$(PKG)_LIBNAMES_SHORT := libtiff
# to include also libtiffxx:
#$(PKG)_LIBNAMES_SHORT := libtiff libtiffxx
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT:%=%.so)

$(PKG)_BINARIES :=$($(PKG)_LIBNAMES_LONG:%=$(PKG)_DIR)/.libs/%)
$(PKG)_STAGING_BINARIES := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_TARGET_BINARIES := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_DEPENDS_ON := zlib
$(PKG)_DEPENDS_ON += jpeg

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg-include-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg-lib-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TIFF_DIR)

$($(PKG)_STAGING_BINARIES): $($(PKG)_BINARIES)
	$(SUBMAKE) -C $(TIFF_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TIFF_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.la)

$($(PKG)_TARGET_BINARIES): $($(PKG)_DEST_DIR)/usr/lib/freetz/%.so: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.so
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARIES)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARIES)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TIFF_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libtiff* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/tiff*

$(pkg)-uninstall:
	$(RM) $(LIBTIFF_TARGET_DIR)/libtiff*.so*

$(PKG_FINISH)
