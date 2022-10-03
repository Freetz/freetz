$(call PKG_INIT_LIB, 2.5.1)
$(PKG)_LIB_VERSION:=1.1.2501
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=db448a626f9313a1a970d636767316a8da32aede70518b8050fa0de7947adc32
$(PKG)_SITE:=https://download.savannah.nongnu.org/releases/attr,http://ftp.de.debian.org/debian/pool/main/a/attr
### WEBSITE:=https://savannah.nongnu.org/projects/attr/
### CHANGES:=https://git.savannah.nongnu.org/cgit/attr.git/log/
### CVSREPO:=https://git.savannah.nongnu.org/cgit/attr.git

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
		install
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
