$(call PKG_INIT_BIN, 1.6.6)
$(PKG)_MAJOR_VERSION:=1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=e5109da756d74c7d98f683f004a539af
$(PKG)_SITE:=http://subversion.tigris.org/downloads/

ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
$(PKG)_LIB_SUFFIX:=a
$(PKG)_BINARY_BUILD_SUBDIR:=
else
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_LIB_SUFFIX:=so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY_BUILD_SUBDIR:=.libs
endif

# Libraries
$(PKG)_LIBNAMES_SHORT := client delta diff fs fs_fs fs_util ra ra_local ra_neon ra_svn repos subr wc
$(PKG)_LIBNAMES_LONG := $(SUBVERSION_LIBNAMES_SHORT:%=libsvn_%-$(SUBVERSION_MAJOR_VERSION))
$(PKG)_LIBS_BUILD_DIR := $(join $(SUBVERSION_LIBNAMES_SHORT:%=$($(PKG)_DIR)/subversion/libsvn_%/.libs/),$(SUBVERSION_LIBNAMES_LONG:%=%.$(SUBVERSION_LIB_SUFFIX)))
$(PKG)_LIBS_STAGING_DIR := $(SUBVERSION_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.$(SUBVERSION_LIB_SUFFIX))
$(PKG)_LIBS_TARGET_DIR := $(SUBVERSION_LIBNAMES_LONG:%=$($(PKG)_DEST_DIR)/usr/lib/%.$(SUBVERSION_LIB_SUFFIX))

# Executables
$(PKG)_BINARIES_ALL := svn svnadmin svndumpfilter svnlook svnserve svnsync svnversion
$(PKG)_BINARIES := $(strip $(foreach binary,$($(PKG)_BINARIES_ALL),$(if $(FREETZ_PACKAGE_$(PKG)_$(shell echo $(binary) | tr [a-z] [A-Z])),$(binary))))
$(PKG)_BINARIES_BUILD_DIR := $(join $(SUBVERSION_BINARIES:%=$($(PKG)_DIR)/subversion/%/$(SUBVERSION_BINARY_BUILD_SUBDIR)/),$(SUBVERSION_BINARIES))
$(PKG)_BINARIES_STAGING_DIR := $(SUBVERSION_BINARIES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $(SUBVERSION_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON := apr
$(PKG)_DEPENDS_ON += apr-util
$(PKG)_DEPENDS_ON += neon
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_DEPENDS_ON += zlib

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_STATIC

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# Rename ac_cv_path_(PERL|PYTHON|RUBY) variables to ensure that only subversion
# uses the values we set (the values are cached in config.cache).
# Not doing so might break the compilation of other packages that do require perl/python/ruby at build-time.
# Setting them to "none" is the simplest way to prevent subversion from building perl/python/ruby-bindings.
$(PKG)_CONFIGURE_PRE_CMDS += sed -i -r -e 's/ac(_cv_path_(PERL|PYTHON|RUBY))/subversion\1/g' ./configure ;
$(PKG)_CONFIGURE_ENV += subversion_cv_path_PERL="none"
$(PKG)_CONFIGURE_ENV += subversion_cv_path_PYTHON="none"
$(PKG)_CONFIGURE_ENV += subversion_cv_path_RUBY="none"

$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-apr-util="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-neon="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --disable-neon-version-check
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-all-static
else
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
endif
$(PKG)_CONFIGURE_OPTIONS += --disable-nls

$(PKG)_CONFIGURE_OPTIONS += --disable-mod-activation
$(PKG)_CONFIGURE_OPTIONS += --disable-javahl
$(PKG)_CONFIGURE_OPTIONS += --disable-keychain # MacOS keychain
$(PKG)_CONFIGURE_OPTIONS += --with-apxs=no
$(PKG)_CONFIGURE_OPTIONS += --with-berkeley-db=no
$(PKG)_CONFIGURE_OPTIONS += --with-ctypesgen=no
$(PKG)_CONFIGURE_OPTIONS += --with-gnome-keyring=no
$(PKG)_CONFIGURE_OPTIONS += --with-jdk=no
$(PKG)_CONFIGURE_OPTIONS += --with-kwallet=no
$(PKG)_CONFIGURE_OPTIONS += --with-sasl=no
$(PKG)_CONFIGURE_OPTIONS += --with-swig=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SUBVERSION_DIR)

$($(PKG)_LIBS_STAGING_DIR) $($(PKG)_BINARIES_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(SUBVERSION_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(SUBVERSION_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.la)

$($(PKG)_LIBS_TARGET_DIR): \
	$($(PKG)_DEST_DIR)/usr/lib/libsvn_%-$(SUBVERSION_MAJOR_VERSION).$(SUBVERSION_LIB_SUFFIX): \
	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsvn_%-$(SUBVERSION_MAJOR_VERSION).$(SUBVERSION_LIB_SUFFIX)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	$(INSTALL_LIBRARY_STRIP)
endif

$($(PKG)_BINARIES_TARGET_DIR): \
	$($(PKG)_DEST_DIR)/usr/bin/%: \
	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/%
	$(INSTALL_BINARY_STRIP)

.PHONY: subversion-keep-required-files-only
$(pkg)-keep-required-files-only: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR) | $(pkg)-clean-not-included--int
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	@#compute transitive closure of all required svn-libraries
	@getlibs() { $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/mipsel-linux-uclibc-readelf -d "$$@" | grep -i "Shared library" | sed -r -e 's|^.*\[(.+)\].*$$|\1|g' | sort -u; }; \
	getsvnlibs() { getlibs "$$@" | grep "libsvn"; }; \
	getsvnlibslist() { local ret=""; for l in `getsvnlibs $$bins \`[ -n "$$libs" ] && (echo "$$libs" | sed -e 's| | '"$(SUBVERSION_DEST_DIR)/usr/lib/"'|g')\``; do ret="$$ret $$l"; done; echo -n "$$ret"; }; \
	\
	bins="$(SUBVERSION_BINARIES_TARGET_DIR)"; libs=""; \
	echo -n "Determining required svn-libraries: "; \
	libs=`getsvnlibslist`; previouslibs=""; \
	while [ "$$libs" != "$$previouslibs" ]; do \
		previouslibs="$$libs"; libs=`getsvnlibslist`; \
	done; \
	echo $$libs; \
	for l in $(SUBVERSION_DEST_DIR)/usr/lib/libsvn*; do \
		lbasename=`echo "$$l" | sed -r -e 's|'"$(SUBVERSION_DEST_DIR)/usr/lib/"'(libsvn[^.]+)[.]so.*|\1|g'`; \
		(echo $$libs | grep -q "$$lbasename" >/dev/null 2>&1) || (echo "Removing unneeded svn-library: $$l"; rm -f $$l) \
	done
endif

$(pkg):

$(pkg)-precompiled: $(pkg)-keep-required-files-only

$(pkg)-clean:
	-$(MAKE) -C $(SUBVERSION_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/svn* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsvn*-$(SUBVERSION_MAJOR_VERSION)* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/subversion-$(SUBVERSION_MAJOR_VERSION)

$(pkg)-uninstall:
	$(RM) \
		$(SUBVERSION_DEST_DIR)/usr/bin/svn* \
		$(SUBVERSION_DEST_DIR)/usr/lib/libsvn*-$(SUBVERSION_MAJOR_VERSION)*

$(PKG_FINISH)
