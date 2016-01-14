$(call PKG_INIT_LIB, 1.1.2)
$(PKG)_LIB_VERSION:=0.5.2
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=0e290078e31211baa7b5886bcc8ab6bc048b9fc83882532da4a1a45e58e907fd
$(PKG)_SITE:=http://downloads.xiph.org/releases/opus

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

# semantic: both functions in libm
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,func_lrintf func_lrint)

$(PKG)_CONFIGURE_OPTIONS += --enable-fixed-point
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPUS_DIR) V=1

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(OPUS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopus.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/opus.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPUS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopus* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/opus.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/opus \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/opus.m4

$(pkg)-uninstall:
	$(RM) $(OPUS_TARGET_DIR)/libopus*.so*

$(PKG_FINISH)
