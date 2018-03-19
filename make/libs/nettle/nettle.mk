$(call PKG_INIT_LIB, 3.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=ae7a42df026550b85daca8389b6a60ba6313b0567f374392e54918588a411e94
$(PKG)_SITE:=@GNU/nettle,http://www.lysator.liu.se/~nisse/archive

$(PKG)_LIBNAMES         := nettle hogweed
$(PKG)_LIBVERSIONS      := 6.4    4.4
$(PKG)_LIBNAMES_LONG    := $(join $($(PKG)_LIBNAMES:%=lib%.so.),$($(PKG)_LIBVERSIONS))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES:%=$($(PKG)_DIR)/lib%.so)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,link_ifunc,,nettle)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,lib_gmp___gmpz_powm_sec)

$(PKG)_DEPENDS_ON += gmp

$(PKG)_CONFIGURE_OPTIONS += --disable-assembler
$(PKG)_CONFIGURE_OPTIONS += --disable-documentation
$(PKG)_CONFIGURE_OPTIONS += --disable-openssl
$(PKG)_CONFIGURE_OPTIONS += --disable-mini-gmp
$(PKG)_CONFIGURE_OPTIONS += --enable-public-key

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
