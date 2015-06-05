$(call PKG_INIT_LIB, 3.1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b40fa88dc32f37a182b6b42092ebb144
$(PKG)_SITE:=@GNU/nettle,http://www.lysator.liu.se/~nisse/archive

$(PKG)_LIBNAMES         := nettle hogweed
$(PKG)_LIBVERSIONS      := 6.1    4.1
$(PKG)_LIBNAMES_LONG    := $(join $($(PKG)_LIBNAMES:%=lib%.so.),$($(PKG)_LIBVERSIONS))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES:%=$($(PKG)_DIR)/lib%.so)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_DEPENDS_ON += gmp

$(PKG)_CONFIGURE_OPTIONS += --disable-assembler
$(PKG)_CONFIGURE_OPTIONS += --disable-documentation
$(PKG)_CONFIGURE_OPTIONS += --disable-openssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NETTLE_DIR) \
		EXTRA_CFLAGS="-ffunction-sections -fdata-sections"

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(NETTLE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-here
	$(PKG_FIX_LIBTOOL_LA) \
		$(NETTLE_LIBNAMES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NETTLE_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/nettle \
		$(NETTLE_LIBNAMES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*) \
		$(NETTLE_LIBNAMES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)

$(pkg)-uninstall:
	$(RM) $(NETTLE_LIBNAMES:%=$(NETTLE_TARGET_DIR)/lib%*.so*)

$(PKG_FINISH)
