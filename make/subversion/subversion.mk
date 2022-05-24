$(call PKG_INIT_BIN,$(if $(FREETZ_PACKAGE_SUBVERSION_VERSION_ABANDON),1.9.12,1.14.2))
$(PKG)_MAJOR_VERSION:=1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH_ABANDON:=3c3a15fd73a21ab55556d7c291cf40e25ade1c070294504aa50b4767db1be397
$(PKG)_HASH_CURRENT:=c9130e8d0b75728a66f0e7038fc77052e671830d785b5616aad53b4810d3cc28
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_SUBVERSION_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@APACHE/subversion
### WEBSITE:=https://subversion.apache.org/
### MANPAGE:=https://subversion.apache.org/quick-start
### CHANGES:=https://subversion.apache.org/docs/release-notes/release-history.html
### CVSREPO:=https://svn.apache.org/viewvc/subversion/

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_SUBVERSION_VERSION_ABANDON),abandon,current)

ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
$(PKG)_LIB_SUFFIX:=a
$(PKG)_BINARY_BUILD_SUBDIR:=
else
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_LIB_SUFFIX:=so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY_BUILD_SUBDIR:=.libs
endif

# Libraries
$(PKG)_LIBNAMES_SHORT := client delta diff fs fs_fs fs_util fs_x ra ra_local ra_serf ra_svn repos subr wc
$(PKG)_LIBNAMES_SHORT += $(if $(FREETZ_PACKAGE_SUBVERSION_WITH_LIBDB),fs_base)
$(PKG)_LIBNAMES_LONG := $(SUBVERSION_LIBNAMES_SHORT:%=libsvn_%-$(SUBVERSION_MAJOR_VERSION))
$(PKG)_LIBS_STAGING_DIR := $(SUBVERSION_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.$(SUBVERSION_LIB_SUFFIX))
$(PKG)_LIBS_TARGET_DIR := $(SUBVERSION_LIBNAMES_LONG:%=$($(PKG)_DEST_LIBDIR)/%.$(SUBVERSION_LIB_SUFFIX))

# Executables
$(PKG)_BINARIES_ALL := svn svnadmin svndumpfilter svnlook svnrdump svnserve svnsync svnversion
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_STAGING_DIR := $(SUBVERSION_BINARIES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $(SUBVERSION_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

# apache modules
$(PKG)_MODULES_ALL := mod_authz_svn mod_dav_svn mod_dontdothat
$(PKG)_MODULES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_MODULES_ALL))
$(PKG)_MODULES_STAGING_DIR := $(SUBVERSION_MODULES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$(APACHE2_LIBEXECDIR)/%.so)
$(PKG)_MODULES_TARGET_DIR := $(SUBVERSION_MODULES:%=$($(PKG)_DEST_DIR)$(APACHE2_LIBEXECDIR)/%.so)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_SUBVERSION_REMOVE_WEBIF),etc/default.subversion etc/init.d/rc.subversion usr/lib/cgi-bin/subversion/ usr/lib/cgi-bin/subversion.cgi)

ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES)),y)
$(PKG)_DEPENDS_ON += apache2
endif
$(PKG)_DEPENDS_ON += apr
$(PKG)_DEPENDS_ON += apr-util
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_SUBVERSION_WITH_LIBDB),db)
$(PKG)_DEPENDS_ON += e2fsprogs
$(PKG)_DEPENDS_ON += expat
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_SUBVERSION_VERSION_ABANDON),,lz4)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_DEPENDS_ON += serf
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_SUBVERSION_VERSION_ABANDON),,utf8proc)
$(PKG)_DEPENDS_ON += zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_VERSION_ABANDON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_VERSION_CURRENT
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_WITH_LIBDB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-apr-util="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-serf="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG)_CONFIGURE_OPTIONS += --with-apxs=$(if $(FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apxs",no)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES),--enable-mod-activation,--disable-mod-activation)

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_APACHE_MODULES)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-apache-libexecdir="$(APACHE2_LIBEXECDIR)"
endif
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
$(PKG)_CONFIGURE_OPTIONS += --with-swig=no


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SUBVERSION_DIR)
	touch $@

$($(PKG)_LIBS_STAGING_DIR) $($(PKG)_BINARIES_STAGING_DIR) $($(PKG)_MODULES_STAGING_DIR): $($(PKG)_DIR)/.compiled
	$(SUBMAKE1) -C $(SUBVERSION_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		install install-tools install-mods-shared
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

$($(PKG)_TARGET_DIR)/.exclude-libraries: $(TOPDIR)/.config $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_MODULES_TARGET_DIR)
	@#compute transitive closure of all required svn-libraries
	@getlibs() { $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-readelf -d "$$@" | grep -i "Shared library" | sed -r -e 's|^.*\[(.+)\].*$$|\1|g' | sort -u; }; \
	getsvnlibs() { getlibs "$$@" | grep "libsvn"; }; \
	getsvnlibslist() { local ret=""; for l in `getsvnlibs $$bins \`[ -n "$$libs" ] && (echo "$$libs" | sed -e 's| | '"$(SUBVERSION_DEST_LIBDIR)/"'|g')\``; do ret="$$ret $$l"; done; echo -n "$$ret"; }; \
	\
	$(RM) $@; \
	\
	bins="$(SUBVERSION_BINARIES_TARGET_DIR) $(SUBVERSION_MODULES_TARGET_DIR)"; libs=""; \
	libs=`getsvnlibslist`; previouslibs=""; \
	while [ "$$libs" != "$$previouslibs" ]; do \
		previouslibs="$$libs"; libs=`getsvnlibslist`; \
	done; \
	for l in $(SUBVERSION_DEST_LIBDIR)/libsvn*; do \
		lbasename=`echo "$$l" | sed -r -e 's|'"$(SUBVERSION_DEST_LIBDIR)/"'(libsvn[^.]+)[.]so.*|\1|g'`; \
		if ! echo $$libs | grep -q "$$lbasename"; then \
			echo $$l | sed -r -e 's,$(SUBVERSION_DEST_DIR)/,,g'; \
		fi; \
	done > $@

$(pkg): $($(PKG)_TARGET_DIR)/.exclude-libraries

$(pkg)-precompiled:


$(pkg)-clean:
	-$(SUBMAKE1) -C $(SUBVERSION_DIR) clean
	$(RM) $(SUBVERSION_DIR)/{.configured,.compiled}
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/svn* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/fsfs* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/{diff,diff3,diff4} \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsvn*-$(SUBVERSION_MAJOR_VERSION)* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/subversion-$(SUBVERSION_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man{1,5,8}/svn* \
		$(SUBVERSION_MODULES_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$(APACHE2_LIBEXECDIR)/%.so)

$(pkg)-uninstall:
	$(RM) \
		$(SUBVERSION_DEST_DIR)/usr/bin/svn* \
		$(SUBVERSION_DEST_LIBDIR)/libsvn*-$(SUBVERSION_MAJOR_VERSION)* \
		$(SUBVERSION_MODULES_ALL:%=$(SUBVERSION_DEST_DIR)$(APACHE2_LIBEXECDIR)/%.so)

$(PKG_FINISH)

