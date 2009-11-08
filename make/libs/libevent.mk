$(call PKG_INIT_LIB, 1.4.12-stable)
$(PKG)_MAJOR_VERSION:=1.4
$(PKG)_SHLIB_VERSION:=2.1.3
$(PKG)_LIBNAME=$(pkg)-$($(PKG)_MAJOR_VERSION).so.$($(PKG)_SHLIB_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.monkey.org/~provos
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)
$(PKG)_SOURCE_MD5:=77b0d8b9885496871bb083165b35ba11

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	   $(SUBMAKE) -C $(LIBEVENT_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
		$(SUBMAKE) -C $(LIBEVENT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-strip
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent.la
	# As we don't (want to) include libevent_{core,extra} into the firmware
	# remove them from the staging dir to prevent other applications
	# from being occasionally linked against them.
	# NB: libevent_{core,extra} is just a split-up of libevent. Everything
	# provided by libevent_{core,extra} is also provided by single libevent.
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent_core*
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent_extra*

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBEVENT_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*

$(pkg)-uninstall:
	$(RM) $(LIBEVENT_TARGET_DIR)/libevent*.so*

$(PKG_FINISH)
