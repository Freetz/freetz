PACKAGE_LC:=avmhmac
PACKAGE_UC:=AVMHMAC
$(PACKAGE_UC)_VERSION:=0.1
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=2.0.0
$(PACKAGE_UC)_SOURCE:=libavmhmac-$($(PACKAGE_UC)_VERSION).tar.bz2
$(PACKAGE_UC)_SITE:=http://dsmod.magenbrot.net
$(PACKAGE_UC)_DIR:=$(SOURCE_DIR)/libavmhmac-$($(PACKAGE_UC)_VERSION)
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/libavmhmac.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_LIB)/libavmhmac.so.$($(PACKAGE_UC)_LIB_VERSION)


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(AVMHMAC_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		all

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(AVMHMAC_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		install DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)"

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac*.so* $(AVMHMAC_DEST_LIB)/
	$(TARGET_STRIP) $@

avmhmac: $($(PACKAGE_UC)_STAGING_BINARY)

avmhmac-precompiled: uclibc avmhmac $($(PACKAGE_UC)_TARGET_BINARY)

avmhmac-configured: $($(PACKAGE_UC)_DIR)/.configured

avmhmac-clean:
	-$(MAKE) -C $(AVMHMAC_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac*

avmhmac-uninstall:
	rm -f $(AVMHMAC_DEST_LIB)/libavmhmac*.so*

$(PACKAGE_FINI)

.PHONY:	avmhmac avmhmac-precompiled avmhmac-source avmhmac-configured avmhmac-clean avmhmac-uninstall avmhmac-dirclean
