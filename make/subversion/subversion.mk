$(call PKG_INIT_BIN, 1.7.10)
$(PKG)_MAJOR_VERSION:=1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA1:=a4f3de0a13b034b0eab4d35512c6c91a4abcf4f5
$(PKG)_SITE:=@APACHE/subversion

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
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_WITH_LIBDB)),y)
$(PKG)_LIBNAMES_SHORT += fs_base
endif
$(PKG)_LIBNAMES_LONG := $(SUBVERSION_LIBNAMES_SHORT:%=libsvn_%-$(SUBVERSION_MAJOR_VERSION))
$(PKG)_LIBS_BUILD_DIR := $(join $(SUBVERSION_LIBNAMES_SHORT:%=$($(PKG)_DIR)/subversion/libsvn_%/.libs/),$(SUBVERSION_LIBNAMES_LONG:%=%.$(SUBVERSION_LIB_SUFFIX)))
$(PKG)_LIBS_STAGING_DIR := $(SUBVERSION_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.$(SUBVERSION_LIB_SUFFIX))
$(PKG)_LIBS_TARGET_DIR := $(SUBVERSION_LIBNAMES_LONG:%=$($(PKG)_DEST_LIBDIR)/%.$(SUBVERSION_LIB_SUFFIX))

# Executables
$(PKG)_BINARIES_ALL := svn svnadmin svndumpfilter svnlook svnrdump svnserve svnsync svnversion
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $(join $(SUBVERSION_BINARIES:%=$($(PKG)_DIR)/subversion/%/$(SUBVERSION_BINARY_BUILD_SUBDIR)/),$(SUBVERSION_BINARIES))
$(PKG)_BINARIES_STAGING_DIR := $(SUBVERSION_BINARIES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $(SUBVERSION_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

# apache modules
$(PKG)_MODULES_ALL := mod_authz_svn mod_dav_svn mod_dontdothat
$(PKG)_MODULES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_MODULES_ALL))
$(PKG)_MODULES_STAGING_DIR := $(SUBVERSION_MODULES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$(APACHE2_LIBEXECDIR)/%.so)
$(PKG)_MODULES_TARGET_DIR := $(SUBVERSION_MODULES:%=$($(PKG)_DEST_DIR)$(APACHE2_LIBEXECDIR)/%.so)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON := apr
$(PKG)_DEPENDS_ON += apr-util
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_WITH_LIBDB)),y)
$(PKG)_DEPENDS_ON += db
endif
$(PKG)_DEPENDS_ON += neon
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_DEPENDS_ON += zlib
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES)),y)
$(PKG)_DEPENDS_ON += apache2
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_WITH_SSL
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
endif
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_WITH_LIBDB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-apr-util="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-neon="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --disable-neon-version-check
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG)_CONFIGURE_OPTIONS += --with-apxs=$(if $(FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apxs",no)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES),--enable-mod-activation,--disable-mod-activation)

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-all-static
else
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
endif
$(PKG)_CONFIGURE_OPTIONS += --disable-nls

$(PKG)_CONFIGURE_OPTIONS += --disable-javahl
$(PKG)_CONFIGURE_OPTIONS += --disable-keychain # MacOS keychain
$(PKG)_CONFIGURE_OPTIONS += --with-berkeley-db=$(if $(FREETZ_PACKAGE_SUBVERSION_WITH_LIBDB),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-ctypesgen=no
$(PKG)_CONFIGURE_OPTIONS += --with-gnome-keyring=no
$(PKG)_CONFIGURE_OPTIONS += --with-jdk=no
$(PKG)_CONFIGURE_OPTIONS += --with-kwallet=no
$(PKG)_CONFIGURE_OPTIONS += --with-sasl=no
$(PKG)_CONFIGURE_OPTIONS += --with-serf=no
$(PKG)_CONFIGURE_OPTIONS += --with-swig=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SUBVERSION_DIR)

$($(PKG)_LIBS_STAGING_DIR) $($(PKG)_BINARIES_STAGING_DIR) $($(PKG)_MODULES_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR)
	$(SUBMAKE1) -C $(SUBVERSION_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(SUBVERSION_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.la)

$($(PKG)_LIBS_TARGET_DIR): \
	$($(PKG)_DEST_LIBDIR)/libsvn_%-$(SUBVERSION_MAJOR_VERSION).$(SUBVERSION_LIB_SUFFIX): \
	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsvn_%-$(SUBVERSION_MAJOR_VERSION).$(SUBVERSION_LIB_SUFFIX)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	$(INSTALL_LIBRARY_STRIP)
endif

$($(PKG)_BINARIES_TARGET_DIR): \
	$($(PKG)_DEST_DIR)/usr/bin/%: \
	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_TARGET_DIR): \
	$($(PKG)_DEST_DIR)$(APACHE2_LIBEXECDIR)/%: \
	$(TARGET_TOOLCHAIN_STAGING_DIR)$(APACHE2_LIBEXECDIR)/%
	$(INSTALL_BINARY_STRIP)

.PHONY: subversion-keep-required-files-only
$(pkg)-keep-required-files-only: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_MODULES_TARGET_DIR) | $(pkg)-clean-not-included--int
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	@#compute transitive closure of all required svn-libraries
	@getlibs() { $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-readelf -d "$$@" | grep -i "Shared library" | sed -r -e 's|^.*\[(.+)\].*$$|\1|g' | sort -u; }; \
	getsvnlibs() { getlibs "$$@" | grep "libsvn"; }; \
	getsvnlibslist() { local ret=""; for l in `getsvnlibs $$bins \`[ -n "$$libs" ] && (echo "$$libs" | sed -e 's| | '"$(SUBVERSION_DEST_LIBDIR)/"'|g')\``; do ret="$$ret $$l"; done; echo -n "$$ret"; }; \
	\
	bins="$(SUBVERSION_BINARIES_TARGET_DIR) $(SUBVERSION_MODULES_TARGET_DIR)"; libs=""; \
	$(call MESSAGE, Determining required svn-libraries: ); \
	libs=`getsvnlibslist`; previouslibs=""; \
	while [ "$$libs" != "$$previouslibs" ]; do \
		previouslibs="$$libs"; libs=`getsvnlibslist`; \
	done; \
	$(call MESSAGE, $$libs); \
	for l in $(SUBVERSION_DEST_LIBDIR)/libsvn*; do \
		lbasename=`echo "$$l" | sed -r -e 's|'"$(SUBVERSION_DEST_LIBDIR)/"'(libsvn[^.]+)[.]so.*|\1|g'`; \
		(echo $$libs | grep -q "$$lbasename" >/dev/null 2>&1) || ($(call MESSAGE, Removing unneeded svn-library: $$l); rm -f $$l) \
	done
endif

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_SUBVERSION_REMOVE_WEBIF)" == "y" ] \
	  && echo "etc/init.d/rc.subversion" >> $@ \
	  && echo "etc/default.subversion/" >> $@ \
	  && echo "usr/lib/cgi-bin/subversion/" >> $@ \
	  && echo "usr/lib/cgi-bin/subversion.cgi" >> $@; \
	touch $@

$(pkg)-precompiled: $(pkg)-keep-required-files-only

$(pkg)-clean:
	-$(SUBMAKE1) -C $(SUBVERSION_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/svn* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsvn*-$(SUBVERSION_MAJOR_VERSION)* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/subversion-$(SUBVERSION_MAJOR_VERSION) \
		$(SUBVERSION_MODULES_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$(APACHE2_LIBEXECDIR)/%.so)

$(pkg)-uninstall:
	$(RM) \
		$(SUBVERSION_DEST_DIR)/usr/bin/svn* \
		$(SUBVERSION_DEST_LIBDIR)/libsvn*-$(SUBVERSION_MAJOR_VERSION)* \
		$(SUBVERSION_MODULES_ALL:%=$(SUBVERSION_DEST_DIR)$(APACHE2_LIBEXECDIR)/%.so)

$(PKG_FINISH)
