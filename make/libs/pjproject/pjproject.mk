$(call PKG_INIT_LIB, 1.0.1)
$(PKG)_LIB_VERSION:=1.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=6462f2a636e5b14f50e92efc000924f0
$(PKG)_SITE:=http://fritz.v3v.de/dtmfbox/libs

$(PKG)_BINARY:=$($(PKG)_DIR)/pjlib/lib/libpj-$(TARGET_ARCH_ENDIANNESS_DEPENDENT)-unknown-linux-gnu.a
$(PKG)_CONFIG_SITE:=$($(PKG)_DIR)/pjlib/include/pj/config_site.h

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
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_G711_CODEC),,--disable-g711-codec)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_GSM_CODEC),,--disable-gsm-codec)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_SPEEX_CODEC),,--disable-speex-codec)
#$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DTMFBOX_WITH_ILBC_CODEC),,--disable-ilbc-codec)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_G711_CODEC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_SPEEX_CODEC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_GSM_CODEC
#$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DTMFBOX_WITH_ILBC_CODEC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$(PJPROJECT_CONFIG_SITE): $($(PKG)_DIR)/.configured
	$(RM) $@
	echo "#undef PJ_OS_HAS_CHECK_STACK"		>> $@
	echo "#define PJ_OS_HAS_CHECK_STACK 0"		>> $@
	echo "#define PJ_TERM_HAS_COLOR 0"		>> $@
	echo "#define PJ_ENABLE_EXTRA_CHECK 0"		>> $@
	echo "#define PJ_DEBUG 0"			>> $@
	echo "#define NDEBUG 0"				>> $@
	echo "#define PJ_LOG_LEVEL_MAX 4"		>> $@
	echo "#define PJ_HAS_ERROR_STRING 0"		>> $@
	echo "#define PJSIP_SAFE_MODULE 0"		>> $@
	echo "#define PJMEDIA_HAS_SRTP 0" 		>> $@
	echo "#define PJ_HAS_FLOATING_POINT 0"		>> $@
	echo "#define SIOCGIFCONF 1"			>> $@
	echo "#undef PJ_HAS_NET_IF_H"			>> $@
	echo "#undef PJ_HAS_IFADDR_H"			>> $@
	echo "#define PJMEDIA_SOUND_IMPLEMENTATION PJMEDIA_SOUND_NULL_SOUND" >> $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured $(PJPROJECT_CONFIG_SITE)
	for target in dep all; do \
		$(SUBMAKE1) -C $(PJPROJECT_DIR) \
		CC_CFLAGS="-Wall -ffunction-sections -fdata-sections" \
		LDFLAGS="-lm" \
		$$target; \
	done

$(pkg): $($(PKG)_BINARY)

$(pkg)-precompiled:

$(pkg)-clean:
	-$(SUBMAKE) -C $(PJPROJECT_DIR) clean

$(PKG_FINISH)
