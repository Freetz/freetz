$(call PKG_INIT_BIN, 2.12.23)
$(PKG)_LIB_VERSION:=26.22.6
$(PKG)_OPENSSL_LIB_VERSION:=27.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=f3c1d34bd5f113395c4be0d5dfc2b7fe
$(PKG)_SITE:=ftp://ftp.$(pkg).org/gcrypt/$(pkg)/v$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_CERTTOOL := certtool
$(PKG)_UTILS := gnutls-cli gnutls-serv psktool srptool
$(PKG)_LIB := libgnutls.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_EXTRA := libgnutls-extra.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_OPENSSL := libgnutls-openssl.so.$($(PKG)_OPENSSL_LIB_VERSION)

$(PKG)_BINARIES_ALL := $($(PKG)_CERTTOOL) $($(PKG)_UTILS)
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_GNUTLS_CERTTOOL),,$($(PKG)_CERTTOOL)) $(if $(FREETZ_PACKAGE_GNUTLS_UTILS),,$($(PKG)_UTILS)),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_LIBS_ALL := $($(PKG)_LIB) $($(PKG)_LIB_EXTRA) $($(PKG)_LIB_OPENSSL)
$(PKG)_LIBS_EXTRA := $(if $(FREETZ_LIB_libgnutls_extra),$($(PKG)_LIB_EXTRA)) $(if $(FREETZ_LIB_libgnutls_openssl),$($(PKG)_LIB_OPENSSL))
$(PKG)_LIBS_BUILD_DIR := $($(PKG)_LIB:%=$($(PKG)_DIR)/lib/.libs/%) $($(PKG)_LIBS_EXTRA:%=$($(PKG)_DIR)/libextra/.libs/%)
$(PKG)_LIBS_STAGING_DIR := $(addprefix $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/,$($(PKG)_LIB) $($(PKG)_LIBS_EXTRA))
$(PKG)_LIBS_TARGET_DIR := $(addprefix $($(PKG)_TARGET_LIBDIR)/,$($(PKG)_LIB) $($(PKG)_LIBS_EXTRA))
$(PKG)_EXCLUDED += $(addprefix $($(PKG)_TARGET_LIBDIR)/, \
	$(if $(FREETZ_LIB_libgnutls_extra),,$($(PKG)_LIB_EXTRA) libgnutls-extra.so.$(call GET_MAJOR_VERSION,$($(PKG)_LIB_VERSION),1) libgnutls-extra.so) \
	$(if $(FREETZ_LIB_libgnutls_openssl),,$($(PKG)_LIB_OPENSSL) libgnutls-openssl.so.$(call GET_MAJOR_VERSION,$($(PKG)_OPENSSL_LIB_VERSION),1) libgnutls-openssl.so) \
)

$(PKG)_DEPENDS_ON += libgpg-error libgcrypt libtasn1 zlib

$(PKG)_ALL_CONFIGURE_SCRIPTS := ./configure ./lib/configure ./libextra/configure

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,$($(PKG)_ALL_CONFIGURE_SCRIPTS))

# fix (a lof of) incorrect configure tests
#   while looking for cached value       gl_cv_have_decl_SOMETHING is used
#   while setting the result of the test ac_cv_have_decl_SOMETHING is used
# and avoid caching of all gl_cv_* values
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,ac_cv_have_decl,gl_cv_have_decl,g' -e 's,gl_cv_,gl_,g' $($(PKG)_ALL_CONFIGURE_SCRIPTS);

# rename all *read_file* functions to avoid name clashing
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,(f?read_file|read_binary_file),gnutls_\1,g' gl/*.{h,c} gl/tests/*.{h,c} lib/gl/*.{h,c} lib/gl/tests/*.{h,c} src/*.{h,c} lib/*.{h,c} lib/openpgp/*.{h,c};

$(PKG)_CONFIGURE_ENV += ac_cv_path_GAA=false

$(PKG)_CONFIGURE_ENV += gl_lib_readline=no
$(PKG)_CONFIGURE_OPTIONS += --with-libreadline-prefix=no

# GnuTLS configure scripts are horribly broken, the documented '--disable-threads' simply doesn't work
# all the lines below are necessary in order to disable threading support
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,ac_cv_libpthread,gl_libpthread,g' $($(PKG)_ALL_CONFIGURE_SCRIPTS);
$(PKG)_CONFIGURE_ENV += gl_libpthread=no
$(PKG)_CONFIGURE_OPTIONS += --enable-threads=no
$(PKG)_CONFIGURE_OPTIONS += --with-libpthread-prefix=no

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-cxx
$(PKG)_CONFIGURE_OPTIONS += --disable-guile
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-html
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-pdf
$(PKG)_CONFIGURE_OPTIONS += --disable-openpgp-authentication
$(PKG)_CONFIGURE_OPTIONS += --with-included-libcfg
$(PKG)_CONFIGURE_OPTIONS += --with-libgcrypt
$(PKG)_CONFIGURE_OPTIONS += --with-libgcrypt-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libtasn1-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libz-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-lzo=no
$(PKG)_CONFIGURE_OPTIONS += --with-p11-kit=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GNUTLS_DIR) V=1

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
