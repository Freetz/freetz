PACKAGE_LC:=avmhmac
PACKAGE_UC:=AVMHMAC
AVMHMAC_VERSION:=0.1
AVMHMAC_LIB_VERSION:=2.0.0
AVMHMAC_SOURCE:=libavmhmac-$(AVMHMAC_VERSION).tar.bz2
AVMHMAC_SITE:=http://dsmod.magenbrot.net
AVMHMAC_MAKE_DIR:=$(MAKE_DIR)/libs
AVMHMAC_DIR:=$(SOURCE_DIR)/libavmhmac-$(AVMHMAC_VERSION)
AVMHMAC_BINARY:=$(AVMHMAC_DIR)/libavmhmac.so.$(AVMHMAC_LIB_VERSION)
AVMHMAC_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac.so.$(AVMHMAC_LIB_VERSION)
AVMHMAC_TARGET_DIR:=root/lib
AVMHMAC_TARGET_BINARY:=$(AVMHMAC_TARGET_DIR)/libavmhmac.so.$(AVMHMAC_LIB_VERSION)


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_LIB_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$(AVMHMAC_BINARY): $(AVMHMAC_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(AVMHMAC_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		all

$(AVMHMAC_STAGING_BINARY): $(AVMHMAC_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(AVMHMAC_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		install DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)"

$(AVMHMAC_TARGET_BINARY): $(AVMHMAC_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac*.so* $(AVMHMAC_TARGET_DIR)/
	$(TARGET_STRIP) $@

avmhmac: $(AVMHMAC_STAGING_BINARY)

avmhmac-precompiled: uclibc avmhmac $(AVMHMAC_TARGET_BINARY)

avmhmac-source: $(AVMHMAC_DIR)/.unpacked
avmhmac-configured: $(AVMHMAC_DIR)/.configured

avmhmac-clean:
	-$(MAKE) -C $(AVMHMAC_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libavmhmac*

avmhmac-uninstall:
	rm -f $(AVMHMAC_TARGET_DIR)/libavmhmac*.so*

avmhmac-dirclean:
	rm -rf $(AVMHMAC_DIR)

.PHONY:	avmhmac avmhmac-precompiled avmhmac-source avmhmac-configured avmhmac-clean avmhmac-uninstall avmhmac-dirclean
