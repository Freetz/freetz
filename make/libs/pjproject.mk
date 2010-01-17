$(call PKG_INIT_LIB, 1.0.1)
$(PKG)_LIB_VERSION:=1.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://fritz.v3v.de/dtmfbox/libs
$(PKG)_BINARY:=$($(PKG)_DIR)/pjsip/lib/libpjsip.a
$(PKG)_CONFIG_SITE:=$(PJPROJECT_DIR)/pjlib/include/pj/config_site.h
$(PKG)_STAGING_BINARY:=$(PJPROJECT_DIR)/pjproject.build
# only static lib
#$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpjsip.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=6462f2a636e5b14f50e92efc000924f0

$(PKG)_CONFIGURE_OPTIONS += --disable-sound
$(PKG)_CONFIGURE_OPTIONS += --disable-oss
$(PKG)_CONFIGURE_OPTIONS += --disable-large-filter
$(PKG)_CONFIGURE_OPTIONS += --disable-small-filter
$(PKG)_CONFIGURE_OPTIONS += --disable-ssl
$(PKG)_CONFIGURE_OPTIONS += --disable-floating-point
$(PKG)_CONFIGURE_OPTIONS += --disable-libsamplerate
$(PKG)_CONFIGURE_OPTIONS += --disable-srtp
$(PKG)_CONFIGURE_OPTIONS += --disable-l16-codec
$(PKG)_CONFIGURE_OPTIONS += --disable-g722-codec
$(PKG)_CONFIGURE_OPTIONS += --disable-speex-aec
$(PKG)_CONFIGURE_OPTIONS += --disable-ilbc-codec
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_GSM_CODEC),,--disable-gsm-codec)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_SPEEX_CODEC),,--disable-speex-codec)
#$(PKG)_CONFIGURE_OPTIONS += --disable-speex-codec
#$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_G711_CODEC),,--disable-g711-codec)
#$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_ILBC_CODEC),,--disable-ilbc-codec)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.depend: $($(PKG)_DIR)/.configured
	cd $(PJPROJECT_DIR)
	rm -f $(PJPROJECT_CONFIG_SIZE)
	echo "#undef PJ_OS_HAS_CHECK_STACK"		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJ_OS_HAS_CHECK_STACK 0"		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJ_TERM_HAS_COLOR 0"		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJ_ENABLE_EXTRA_CHECK 0"		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJ_DEBUG 0"			>> $(PJPROJECT_CONFIG_SITE)
	echo "#define NDEBUG 0"				>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJ_LOG_LEVEL_MAX 4"		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJ_HAS_ERROR_STRING 0"		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJSIP_SAFE_MODULE 0"		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJMEDIA_HAS_SRTP 0" 		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define PJ_HAS_FLOATING_POINT 0"		>> $(PJPROJECT_CONFIG_SITE)
	echo "#define SIOCGIFCONF 1"			>> $(PJPROJECT_CONFIG_SITE)	
	echo "#undef PJ_HAS_NET_IF_H"			>> $(PJPROJECT_CONFIG_SITE)	
	echo "#undef PJ_HAS_IFADDR_H"			>> $(PJPROJECT_CONFIG_SITE)	
	echo "#define PJMEDIA_SOUND_IMPLEMENTATION PJMEDIA_SOUND_NULL_SOUND" >> $(PJPROJECT_CONFIG_SITE)
	PATH=$(TARGET_PATH) \
		LDFLAGS="-lm" \
		$(MAKE) -C $(PJPROJECT_DIR) dep
	touch $@

$($(PKG)_STAGING_BINARY): $($(PKG)_DIR)/.depend
	cd $(PJPROJECT_DIR)
	PATH=$(TARGET_PATH) \
		LDFLAGS="-lm" \
		$(MAKE1) -C $(PJPROJECT_DIR)
	touch $@

#$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
#	cd $(PJPROJECT_DIR)
#	PATH=$(TARGET_PATH) \
#		$(MAKE1) -C $(PJPROJECT_DIR) LDFLAGS="-lm" \
#		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
#	install
#	touch $@

#$(PJSIP_TARGET_BINARY): $(PJSIP_STAGING_BINARY)
#	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip*.so* $(PJPROJECT_TARGET_DIR)
#	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled:

$(pkg)-clean:
	-$(MAKE) -C $(PJPROJECT_DIR) \
		TARGET_NAME="$(REAL_GNU_TARGET_NAME)" \
		clean
#		rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/local/lib/libpj*.a \
#		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/local/lib/libresample-*.a \
#		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/local/lib/libsrtp-*.a \
#		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/local/lib/libmilenage-*.a

#$(pkg)-uninstall:
#	rm -f $(PJPROJECT_TARGET_DIR)/libpjsip*.so*

$(PKG_FINISH)
