$(call PKG_INIT_BIN, 2.8.6)
$(PKG)_LIB_VERSION:=26.14.12
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=eb0a6d7d3cb9ac684d971c14f9f6d3ba
$(PKG)_SITE:=ftp://ftp.gnu.org/pub/gnu/gnutls

$(PKG)_CERTTOOL := certtool
$(PKG)_UTILS := gnutls-cli gnutls-serv psktool srptool
$(PKG)_LIB := libgnutls.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_EXTRA := libgnutls-extra.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_OPENSSL := libgnutls-openssl.so.$($(PKG)_LIB_VERSION)

$(PKG)_BINARIES_ALL := $($(PKG)_CERTTOOL) $($(PKG)_UTILS)
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_GNUTLS_CERTTOOL),,$($(PKG)_CERTTOOL)) $(if $(FREETZ_PACKAGE_GNUTLS_UTILS),,$($(PKG)_UTILS)),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_NOT_INCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_LIBS_ALL := $($(PKG)_LIB) $($(PKG)_LIB_EXTRA) $($(PKG)_LIB_OPENSSL)
$(PKG)_LIBS_EXTRA := $(if $(FREETZ_LIB_libgnutls_extra),$($(PKG)_LIB_EXTRA)) $(if $(FREETZ_LIB_libgnutls_openssl),$($(PKG)_LIB_OPENSSL))
$(PKG)_LIBS_BUILD_DIR := $($(PKG)_LIB:%=$($(PKG)_DIR)/lib/.libs/%) $($(PKG)_LIBS_EXTRA:%=$($(PKG)_DIR)/libextra/.libs/%)
$(PKG)_LIBS_STAGING_DIR := $(addprefix $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/,$($(PKG)_LIB) $($(PKG)_LIBS_EXTRA))
$(PKG)_LIBS_TARGET_DIR := $(addprefix $($(PKG)_TARGET_LIBDIR)/,$($(PKG)_LIB) $($(PKG)_LIBS_EXTRA))
$(PKG)_NOT_INCLUDED += $(addprefix $($(PKG)_TARGET_LIBDIR)/, \
	$(if $(FREETZ_LIB_libgnutls_extra),,$($(PKG)_LIB_EXTRA) libgnutls-extra.so.26 libgnutls-extra.so) \
	$(if $(FREETZ_LIB_libgnutls_openssl),,$($(PKG)_LIB_OPENSSL) libgnutls-openssl.so.26 libgnutls-openssl.so) \
)

$(PKG)_DEPENDS_ON += libgpg-error libgcrypt libtasn1 zlib

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure ./lib/configure ./libextra/configure)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,header_readline_readline_h)

# rename all *read_file* functions to avoid name clashing
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,(f?read_file|read_binary_file),gnutls_\1,g' gl/*.{h,c} gl/tests/*.{h,c} lib/gl/*.{h,c} lib/gl/tests/*.{h,c} src/*.{h,c} lib/*.{h,c} lib/openpgp/*.{h,c};

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-cxx
$(PKG)_CONFIGURE_OPTIONS += --disable-guile
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-html
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-pdf
$(PKG)_CONFIGURE_OPTIONS += --disable-openpgp-authentication
$(PKG)_CONFIGURE_OPTIONS += --with-included-libcfg
$(PKG)_CONFIGURE_OPTIONS += --with-libgcrypt-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libtasn1-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libreadline-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libz-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-lzo=no
$(PKG)_CONFIGURE_OPTIONS += --without-libreadline-prefix

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GNUTLS_DIR)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(GNUTLS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgnutls*.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gnutls*.pc

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GNUTLS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgnutls* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gnutls*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gnutls \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/{certtool,gnutls*,psktool,srptool}

$(pkg)-uninstall:
	$(RM) $(GNUTLS_BINARIES_ALL:%=$(GNUTLS_DEST_DIR)/usr/bin/%) $(GNUTLS_TARGET_LIBDIR)/libgnutls*

$(PKG_FINISH)
