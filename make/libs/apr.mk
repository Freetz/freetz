$(call PKG_INIT_LIB, 1.3.9)
$(PKG)_MAJOR_VERSION:=1
$(PKG)_LIB_VERSION:=0.3.9
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=7138ac64d4458eeeaa9b9aefa4e6e51b
$(PKG)_SITE:=http://apache.mirroring.de/apr/
$(PKG)_MAJOR_LIBNAME=libapr-$(APR_MAJOR_VERSION)
$(PKG)_LIBNAME=$($(PKG)_MAJOR_LIBNAME).so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)
$(PKG)_INCLUDE_DIR:=/usr/include/apr-$(APR_MAJOR_VERSION)
$(PKG)_BUILD_DIR:=/usr/share/apr-$(APR_MAJOR_VERSION)/build

$(PKG)_DEPENDS_ON := e2fsprogs
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_STATIC

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_zero=yes
$(PKG)_CONFIGURE_ENV += ac_cv_sizeof_struct_iovec=8
$(PKG)_CONFIGURE_ENV += apr_cv_process_shared_works=no
$(PKG)_CONFIGURE_ENV += apr_cv_mutex_robust_shared=no
$(PKG)_CONFIGURE_ENV += apr_cv_tcp_nodelay_with_cork=yes

# disable threads in libapr until svn-client problems are solved
#$(PKG)_CONFIGURE_ENV += apr_cv_pthreads_lib=-lpthread
#$(PKG)_CONFIGURE_OPTIONS += --enable-threads
$(PKG)_CONFIGURE_OPTIONS += --disable-threads

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-dso
$(PKG)_CONFIGURE_OPTIONS += --with-devrandom=/dev/urandom
$(PKG)_CONFIGURE_OPTIONS += --includedir=$(APR_INCLUDE_DIR)
$(PKG)_CONFIGURE_OPTIONS += --with-installbuilddir=$(APR_BUILD_DIR)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(APR_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(APR_DIR)\
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(APR_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/apr-$(APR_MAJOR_VERSION).pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-$(APR_MAJOR_VERSION)-config
	# additional fixes not (yet?) covered by $(PKG_FIX_LIBTOOL_LA)
	sed -i -r $(foreach key,bindir datarootdir datadir installbuilddir,$(call PKG_FIX_LIBTOOL_LA__INT,$(key))) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-$(APR_MAJOR_VERSION)-config
	sed -i -r $(foreach key,apr_builddir apr_builders,$(call PKG_FIX_LIBTOOL_LA__INT,$(key))) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/$(APR_BUILD_DIR)/apr_rules.mk

	# fixes taken from openwrt
	sed -i -e 's|-[LR][$$]libdir||g' $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-$(APR_MAJOR_VERSION)-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(APR_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(APR_MAJOR_LIBNAME)* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/apr-$(APR_MAJOR_VERSION).pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-$(APR_MAJOR_VERSION)-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/apr.exp \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/$(APR_INCLUDE_DIR)/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/$(APR_BUILD_DIR)/

$(pkg)-uninstall:
	$(RM) $(APR_TARGET_DIR)/$(APR_MAJOR_LIBNAME).so*

$(PKG_FINISH)
