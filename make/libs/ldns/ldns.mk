$(call PKG_INIT_LIB, 1.7.1)
$(PKG)_LIB_VERSION:=3.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=8ac84c16bdca60e710eea75782356f3ac3b55680d40e1530d7cea474ac208229
$(PKG)_SITE:=https://www.nlnetlabs.nl/downloads/$(pkg)/
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcrypto_WITH_EC
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_VERSION_1_MAX

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := openssl libpcap

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libcrypto_WITH_EC),--enable-ecdsa,--disable-ecdsa)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_OPENSSL_VERSION_1_MAX),--enable-gost,--disable-gost)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_OPENSSL_VERSION_1_MAX),--disable-dane-verify,--enable-dane-verify)
$(PKG)_CONFIGURE_OPTIONS += --without-pyldns
$(PKG)_CONFIGURE_OPTIONS += --disable-ldns-config
$(PKG)_CONFIGURE_OPTIONS += --with-pcap=yes
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(LDNS_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE1) -C $(LDNS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libldns.a

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE1) -C $(LDNS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libldns* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/*ldns.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/*ldns \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/man/man?/ldns*

$(pkg)-uninstall:
	$(RM) $(LDNS_TARGET_DIR)/libldns*.so*

$(PKG_FINISH)

