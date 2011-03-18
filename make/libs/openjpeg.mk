$(call PKG_INIT_LIB, 1_4)
$(PKG)_LIB_VERSION:=1.4.0
$(PKG)_TARBALL_DIR:=$(pkg)_v$($(PKG)_VERSION)_sources_r697
$(PKG)_SOURCE:=$($(PKG)_TARBALL_DIR).tgz
$(PKG)_SOURCE_MD5:=7870bb84e810dec63fcf3b712ebb93db
$(PKG)_SITE:=http://openjpeg.googlecode.com/files

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$($(PKG)_TARBALL_DIR)

$(PKG)_BINARY:=$($(PKG)_DIR)/libopenjpeg/.libs/libopenjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libopenjpeg.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += zlib

$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 configure.ac aclocal.m4;

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG)_CONFIGURE_OPTIONS += --enable-jp3d=no
$(PKG)_CONFIGURE_OPTIONS += --enable-jpwl=no
$(PKG)_CONFIGURE_OPTIONS += --enable-lcms1=no
$(PKG)_CONFIGURE_OPTIONS += --enable-lcms2=no
$(PKG)_CONFIGURE_OPTIONS += --enable-png=no
$(PKG)_CONFIGURE_OPTIONS += --enable-tiff=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENJPEG_DIR)/libopenjpeg \
		FREETZ_CFLAGS="$(TARGET_CFLAGS)" \
		libopenjpeg.la

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(OPENJPEG_DIR)/libopenjpeg \
		includedir=/usr/include \
		DESTDIR=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		install-includeHEADERS install-libLTLIBRARIES
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenjpeg.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENJPEG_DIR) clean
	rm -f \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/openjpeg.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenjpeg*

$(pkg)-uninstall:
	$(RM) $(OPENJPEG_TARGET_DIR)/libopenjpeg*.so*

$(PKG_FINISH)
