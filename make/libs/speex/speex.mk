$(call PKG_INIT_LIB, 1.2rc1)
$(PKG)_LIB_VERSION:=1.5.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=342f30dc57bd4a6dad41398365baaa690429660b10d866b7d508e8f1179cb7a6
$(PKG)_SITE:=http://downloads.xiph.org/releases/speex

$(PKG)_LIBNAMES_SHORT   := speex speexdsp
$(PKG)_LIBNAMES_LONG    := $($(PKG)_LIBNAMES_SHORT:%=lib%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/libspeex/.libs/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

# needed for speexdec/speexenc only, not needed for libraries
$(PKG)_DEPENDS_ON += libogg

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-fixed-point
$(PKG)_CONFIGURE_OPTIONS += --disable-float-api
$(PKG)_CONFIGURE_OPTIONS += --disable-vbr
$(PKG)_CONFIGURE_OPTIONS += --disable-oggtest
$(PKG)_CONFIGURE_OPTIONS += --with-ogg="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SPEEX_DIR)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(SPEEX_DIR)/libspeex \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES
	$(SUBMAKE) -C $(SPEEX_DIR)/include/speex \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-pkgincludeHEADERS install-nodist_pkgincludeHEADERS
	$(SUBMAKE) -C $(SPEEX_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-pkgconfigDATA
	$(PKG_FIX_LIBTOOL_LA) \
		$(SPEEX_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.la) \
		$(SPEEX_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SPEEX_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libspeex*.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/speex*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/speex

$(pkg)-uninstall:
	$(RM) $(SPEEX_TARGET_DIR)/libspeex.so*

$(PKG_FINISH)
