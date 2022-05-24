$(call PKG_INIT_LIB, 1.4.4)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION)+20100615~dfsg.orig.tar.gz
$(PKG)_HASH:=ddcd1e84129e611bedad7f23b94ed8c446dc762a627543d59c38b5f048d7dcb1
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/s/srtp

$(PKG)_BINARY:=$($(PKG)_DIR)/lib$(pkg).so.$($(PKG)_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/lib$(pkg).so.$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/lib$(pkg).so.$($(PKG)_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --disable-stdout
$(PKG)_CONFIGURE_OPTIONS += --disable-console
$(PKG)_CONFIGURE_OPTIONS += --enable-syslog
$(PKG)_CONFIGURE_OPTIONS += --disable-gdoi

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SRTP_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(SRTP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SRTP_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsrtp.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/srtp

$(pkg)-uninstall:
	$(RM) $(SRTP_TARGET_DIR)/libsrtp.so*

$(PKG_FINISH)
