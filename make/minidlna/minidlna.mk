$(call PKG_INIT_BIN, 1.0.26)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c8347c0ce44579f9ff2ca24676dcc5f7
$(PKG)_SITE:=@SF/minidlna

$(PKG)_BINARY := $($(PKG)_DIR)/minidlna
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/sbin/minidlna

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINIDLNA_STATIC

$(PKG)_DEPENDS_ON += ffmpeg libexif flac libid3tag jpeg libogg libvorbis sqlite
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
$(PKG)_ICONV_LIB += -liconv
endif

$(PKG)_CONFIGURE_PRE_CMDS += ln -s genconfig.sh configure;
$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV := CROSS_TOOLCHAIN_SYSROOT="$(TARGET_TOOLCHAIN_STAGING_DIR)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINIDLNA_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LINK_STATICALLY="$(if $(FREETZ_PACKAGE_MINIDLNA_STATIC),yes,no)" \
		FFMPEG_EXTRA_LIBS="$(if $(FREETZ_PACKAGE_FFMPEG_DECODER_libopenjpeg),-lopenjpeg)" \
		ICONV_LIB="$(MINIDLNA_ICONV_LIB)" \
		CROSS_TOOLCHAIN_SYSROOT="$(TARGET_TOOLCHAIN_STAGING_DIR)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MINIDLNA_DIR) clean
	$(RM) $(MINIDLNA_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MINIDLNA_TARGET_BINARY)

$(PKG_FINISH)
