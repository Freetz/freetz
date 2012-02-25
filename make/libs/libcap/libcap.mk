$(call PKG_INIT_LIB, 2.22)
$(PKG)_LIB_VERSION:=2.22
$(PKG)_SOURCE:=$(pkg)2_$($(PKG)_LIB_VERSION).orig.tar.gz
$(PKG)_SOURCE_MD5:=b4896816b626bea445f0b3849bdd4077
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/libc/libcap2

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := attr

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBCAP_DIR) \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)" \
		CFLAGS="$(TARGET_CFLAGS) -fPIC -I$(realpath $(LIBCAP_DIR))/libcap/include" \
		BUILD_CC="$(CC)" \
		BUILD_CFLAGS="-O -I$(realpath $(LIBCAP_DIR))/libcap/include" \
		lib=lib \

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBCAP_DIR)/libcap \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		lib=lib \
		RAISE_SETFCAP=no \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBCAP_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/libcap.so* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/libcap.a*

$(pkg)-uninstall:
	$(RM) $(LIBCAP_TARGET_DIR)/libcap.so*

$(PKG_FINISH)

