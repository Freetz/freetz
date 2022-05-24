$(call PKG_INIT_BIN, 3.6.16)
$(PKG)_LIB_VERSION:=30.28.2
$(PKG)_OPENSSL_LIB_VERSION:=27.0.2
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=1b79b381ac283d8b054368b335c408fedcb9b7144e0c07f531e3537d4328f3b3
$(PKG)_SITE:=https://www.gnupg.org/ftp/gcrypt/gnutls/v$(call GET_MAJOR_VERSION,$($(PKG)_VERSION)),ftp://ftp.gnutls.org/gcrypt/gnutls/v$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
### WEBSITE:=https://www.gnutls.org/
### MANPAGE:=https://www.gnutls.org/documentation.html
### CHANGES:=https://www.gnutls.org/news.html
### CVSREPO:=https://gitlab.com/gnutls/gnutls

$(PKG)_CERTTOOL := certtool
$(PKG)_UTILS := gnutls-cli gnutls-serv psktool srptool
$(PKG)_LIB := libgnutls.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_OPENSSL := libgnutls-openssl.so.$($(PKG)_OPENSSL_LIB_VERSION)

$(PKG)_BINARIES_ALL := $($(PKG)_CERTTOOL) $($(PKG)_UTILS)
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_GNUTLS_CERTTOOL),,$($(PKG)_CERTTOOL)) $(if $(FREETZ_PACKAGE_GNUTLS_UTILS),,$($(PKG)_UTILS)),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_LIBS_BUILD_DIR := $($(PKG)_LIB:%=$($(PKG)_DIR)/lib/.libs/%) $(if $(FREETZ_LIB_libgnutls_openssl),$($(PKG)_LIB_OPENSSL:%=$($(PKG)_DIR)/extra/.libs/%))
$(PKG)_LIBS_STAGING_DIR := $(addprefix $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/,$($(PKG)_LIB) $(if $(FREETZ_LIB_libgnutls_openssl),$($(PKG)_LIB_OPENSSL)))
$(PKG)_LIBS_TARGET_DIR := $(addprefix $($(PKG)_TARGET_LIBDIR)/,$($(PKG)_LIB) $(if $(FREETZ_LIB_libgnutls_openssl),$($(PKG)_LIB_OPENSSL)))

$(PKG)_EXCLUDED += $(addprefix $($(PKG)_TARGET_LIBDIR)/, \
	$(if $(FREETZ_LIB_libgnutls_openssl),,$($(PKG)_LIB_OPENSSL) libgnutls-openssl.so.$(call GET_MAJOR_VERSION,$($(PKG)_OPENSSL_LIB_VERSION),1) libgnutls-openssl.so) \
)

$(PKG)_DEPENDS_ON += libtasn1 zlib nettle

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
# avoid caching of all gl_cv_* values
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,gl_cv_,gl_,g' ./configure;

# disable threading support
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,ac_cv_libpthread,gl_libpthread,g' ./configure;
$(PKG)_CONFIGURE_ENV += gl_libpthread=no
$(PKG)_CONFIGURE_OPTIONS += --with-libpthread-prefix=no

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-cxx
$(PKG)_CONFIGURE_OPTIONS += --disable-dane
$(PKG)_CONFIGURE_OPTIONS += --disable-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-guile
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-html
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-pdf
$(PKG)_CONFIGURE_OPTIONS += --disable-tests
$(PKG)_CONFIGURE_OPTIONS += --disable-openpgp-authentication
$(PKG)_CONFIGURE_OPTIONS += --enable-openssl-compatibility
$(PKG)_CONFIGURE_OPTIONS += --with-included-libcfg
$(PKG)_CONFIGURE_OPTIONS += --with-included-unistring
$(PKG)_CONFIGURE_OPTIONS += --with-libtasn1-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libz-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libnsl-prefix=no
$(PKG)_CONFIGURE_OPTIONS += --with-idn=no
$(PKG)_CONFIGURE_OPTIONS += --with-lzo=no
$(PKG)_CONFIGURE_OPTIONS += --with-p11-kit=no
$(PKG)_CONFIGURE_OPTIONS += --with-tpm=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GNUTLS_DIR) CFLAGS="-fcommon"

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

$(call PKG_ADD_LIB,libgnutls)
$(PKG_FINISH)
