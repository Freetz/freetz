$(eval $(call PKG_INIT_LIB, 0.1))
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=libavmhmac-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://dsmod.magenbrot.net
$(PKG)_DIR:=$(SOURCE_DIR)/libavmhmac-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/libavmhmac.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_LIB)/libavmhmac.so.$($(PKG)_LIB_VERSION)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(AVMHMAC_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(AVMHMAC_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		install DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)"

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac*.so* $(AVMHMAC_DEST_LIB)/
	$(TARGET_STRIP) $@

avmhmac: $($(PKG)_STAGING_BINARY)

avmhmac-precompiled: uclibc openssl-precompiled avmhmac $($(PKG)_TARGET_BINARY)

avmhmac-configured: $($(PKG)_DIR)/.configured

avmhmac-clean:
	-$(MAKE) -C $(AVMHMAC_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac*

avmhmac-uninstall:
	rm -f $(AVMHMAC_DEST_LIB)/libavmhmac*.so*

$(PKG_FINISH)

.PHONY:	avmhmac avmhmac-precompiled avmhmac-source avmhmac-configured avmhmac-clean avmhmac-uninstall avmhmac-dirclean
