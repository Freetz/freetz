$(call PKG_INIT_LIB, 2.4.44)
$(PKG)_LIB_VERSION:=1.1.0
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_HASH:=9f6214b8e53f4bba651ac5a72c0f6193b12aa21fbf1d675d89a7b4bc45264498
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/a/attr

$(PKG)_BINARY:=$($(PKG)_DIR)/libattr/.libs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-gettext=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ATTR_DIR) \
		OPTIMIZER="" DEBUG="" \
		PCFLAGS="-D_GNU_SOURCE" \
		LCFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(ATTR_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		include-install-dev libattr-install-dev libattr-install-lib
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libattr.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ATTR_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/attr \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libattr.*

$(pkg)-uninstall:
	$(RM) $(ATTR_TARGET_DIR)/libattr.so*

$(PKG_FINISH)
