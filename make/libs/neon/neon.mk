$(call PKG_INIT_LIB, $(if $(FREETZ_KERNEL_VERSION_2_MAX),0.30.2,0.32.2))
$(PKG)_LIB_VERSION:=$(if $(FREETZ_KERNEL_VERSION_2_MAX),27.3.2,27.5.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256_ABANDON:=db0bd8cdec329b48f53a6f00199c92d5ba40b0f015b153718d1b15d3d967fbca
$(PKG)_SOURCE_SHA256_CURRENT:=986566468c6295fc5d0fb141a5981e31c9f82ee38e938374abed8471ef2fb286
$(PKG)_SOURCE_SHA256:=$(NEON_SOURCE_SHA256_$(if $(FREETZ_KERNEL_VERSION_2_MAX),ABANDON,CURRENT))
$(PKG)_SITE:=https://notroj.github.io/neon,http://www.webdav.org/neon
### VERSION:=0.30.2/0.32.2
### WEBSITE:=https://notroj.github.io/neon/
### MANPAGE:=https://github.com/notroj/neon#readme
### CHANGES:=https://notroj.github.io/neon/
### CVSREPO:=https://github.com/notroj/neon

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libneon.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libneon.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libneon.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += expat
ifeq ($(strip $(FREETZ_LIB_libneon_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
endif
ifeq ($(strip $(FREETZ_LIB_libneon_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_KERNEL_VERSION_2_MAX),abandon,current)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --with-expat=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.la
$(PKG)_CONFIGURE_OPTIONS += --with-gssapi
$(PKG)_CONFIGURE_OPTIONS += --disable-nls
$(PKG)_CONFIGURE_OPTIONS += --without-egd
$(PKG)_CONFIGURE_OPTIONS += --without-libproxy
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libneon_WITH_SSL),--with-ssl=openssl,--without-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libneon_WITH_ZLIB),,--without-zlib)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libneon_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libneon_WITH_ZLIB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NEON_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(NEON_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libneon.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/neon.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/neon-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NEON_DIR) clean
	$(RM) $(NEON_FREETZ_CONFIG_FILE)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libneon.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/neon \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/neon.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/neon-config

$(pkg)-uninstall:
	$(RM) $(NEON_TARGET_DIR)/libneon*.so*

$(PKG_FINISH)
