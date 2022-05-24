$(call PKG_INIT_LIB, 2.2.1)
$(PKG)_LIB_VERSION:=2
$(PKG)_SOURCE:=pjproject-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=da1933336b38b65ff2254bed05ea1076531b16915777a252ea999cf7f3284cb3
$(PKG)_SITE:=http://www.pjsip.org/release/$($(PKG)_VERSION)

$(PKG)_INSTALL_SUBDIR:=_install

$(PKG)_LIBNAMES_SHORT   := pj pjlib-util pjmedia pjmedia-audiodev pjmedia-codec pjmedia-videodev pjnath pjsip pjsip-simple pjsip-ua pjsua g7221codec ilbccodec milenage
$(PKG)_LIBNAMES_LONG    := $($(PKG)_LIBNAMES_SHORT:%=lib%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)/usr/lib/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_INCLUDES           := pj pjlib-util pjmedia pjmedia-audiodev pjmedia-codec pjmedia-videodev pjnath pjsip pjsip-simple pjsip-ua pjsua-lib
$(PKG)_INCLUDES           += pjlib.h pjlib-util.h pjmedia_audiodev.h pjmedia-codec.h pjmedia.h pjmedia_videodev.h pjnath.h pjsip_auth.h pjsip.h pjsip_simple.h pjsip_ua.h pjsua.h
$(PKG)_HEADER_BUILD_DIR   := $($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)/usr/include/pjlib.h
$(PKG)_HEADER_STAGING_DIR := $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pjlib.h

$(PKG)_DEPENDS_ON += libgsm speex srtp e2fsprogs

$(PKG)_CONFIGURE_OPTIONS += --enable-shared

$(PKG)_CONFIGURE_OPTIONS += --disable-floating-point
$(PKG)_CONFIGURE_OPTIONS += --disable-epoll

$(PKG)_CONFIGURE_OPTIONS += --disable-resample
$(PKG)_CONFIGURE_OPTIONS += --disable-resample-dll
$(PKG)_CONFIGURE_OPTIONS += --disable-small-filter
$(PKG)_CONFIGURE_OPTIONS += --disable-large-filter
$(PKG)_CONFIGURE_OPTIONS += --disable-libsamplerate

$(PKG)_CONFIGURE_OPTIONS += --disable-ext-sound
$(PKG)_CONFIGURE_OPTIONS += --disable-sound
$(PKG)_CONFIGURE_OPTIONS += --disable-oss
$(PKG)_CONFIGURE_OPTIONS += --disable-video

$(PKG)_CONFIGURE_OPTIONS += --enable-speex-codec
$(PKG)_CONFIGURE_OPTIONS += --enable-speex-aec
$(PKG)_CONFIGURE_OPTIONS += --with-external-speex

$(PKG)_CONFIGURE_OPTIONS += --enable-gsm-codec
$(PKG)_CONFIGURE_OPTIONS += --with-external-gsm

$(PKG)_CONFIGURE_OPTIONS += --enable-l16-codec
$(PKG)_CONFIGURE_OPTIONS += --enable-g711-codec
$(PKG)_CONFIGURE_OPTIONS += --enable-g722-codec
$(PKG)_CONFIGURE_OPTIONS += --enable-g7221-codec
$(PKG)_CONFIGURE_OPTIONS += --enable-ilbc-codec

$(PKG)_CONFIGURE_OPTIONS += --disable-ssl

$(PKG)_CONFIGURE_OPTIONS += --disable-ipp
$(PKG)_CONFIGURE_OPTIONS += --disable-ffmpeg
$(PKG)_CONFIGURE_OPTIONS += --disable-opencore-amr
$(PKG)_CONFIGURE_OPTIONS += --disable-silk
$(PKG)_CONFIGURE_OPTIONS += --disable-sdl
$(PKG)_CONFIGURE_OPTIONS += --disable-v4l2

$(PKG)_CONFIGURE_OPTIONS += --with-external-srtp
$(PKG)_CONFIGURE_OPTIONS += --without-external-pa

$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,[-/][$$$$][(]TARGET_NAME[)],$$$$(TARGET_SUFFIX),g' $$$$(grep -rl -e "[-/][$$$$][(]TARGET_NAME[)]" .);
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,-([$$$$][(]LIB_SUFFIX[)]),\1,g' $$$$(grep -rl -e "-[$$$$][(]LIB_SUFFIX[)]" .);

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	for target in dep all; do \
		$(SUBMAKE1) -C $(PJPROJECT2_DIR) \
		EXTRA_CFLAGS="-fno-strict-aliasing -ffunction-sections -fdata-sections" \
		$$target; \
	done
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(SUBMAKE1) -C $(PJPROJECT2_DIR) \
		DESTDIR="$(abspath $(PJPROJECT2_DIR)/$(PJPROJECT2_INSTALL_SUBDIR))" \
		install
	find $(PJPROJECT2_DIR)/$(PJPROJECT2_INSTALL_SUBDIR) -type f \( -name "*.h.in" -o -name "*.hpp" \) -exec rm \{\} \+
	find $(PJPROJECT2_DIR)/$(PJPROJECT2_INSTALL_SUBDIR) -type d -empty -delete
	@touch $@

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_HEADER_BUILD_DIR): $($(PKG)_DIR)/.installed
	@touch $@

$($(PKG)_LIBS_STAGING_DIR): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%: $($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)/usr/lib/%
	$(INSTALL_LIBRARY_INCLUDE_STATIC)

$($(PKG)_HEADER_STAGING_DIR): $($(PKG)_HEADER_BUILD_DIR)
	cp -a $(PJPROJECT2_INCLUDES:%=$(PJPROJECT2_DIR)/$(PJPROJECT2_INSTALL_SUBDIR)/usr/include/%) $(dir $@)
	@touch $@

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR) $($(PKG)_HEADER_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PJPROJECT2_DIR) clean
	$(RM) $(PJPROJECT2_DIR)/{.configured,.compiled,.installed}
	$(RM) -r \
		$(PJPROJECT2_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.so*) \
		$(PJPROJECT2_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.a) \
		$(PJPROJECT2_INCLUDES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/%)

$(pkg)-uninstall:
	$(RM) $(PJPROJECT2_LIBNAMES_SHORT:%=$(PJPROJECT2_TARGET_DIR)/lib%.so*)

$(PKG_FINISH)
