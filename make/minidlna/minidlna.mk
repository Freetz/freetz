$(call PKG_INIT_BIN, 1.1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=26484a84af3fceafdee26595aae097f7
$(PKG)_SITE:=@SF/minidlna

$(PKG)_BINARY := $($(PKG)_DIR)/minidlnad
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/sbin/minidlna

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINIDLNA_STATIC

$(PKG)_DEPENDS_ON += ffmpeg libexif flac libid3tag jpeg libogg libvorbis sqlite
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
$(PKG)_ICONV_LIB += -liconv
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)"
else
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
endif

$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-netgear
$(PKG)_CONFIGURE_OPTIONS += --disable-readynas
$(PKG)_CONFIGURE_OPTIONS += --enable-tivo
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_MINIDLNA_STATIC),--enable-static,--disable-static)
$(PKG)_CONFIGURE_OPTIONS += --with-log-path="/var/log"
$(PKG)_CONFIGURE_OPTIONS += --with-db-path="/tmp/minidlna"
$(PKG)_CONFIGURE_OPTIONS += --with-os-name="FRITZ!Box"
$(PKG)_CONFIGURE_OPTIONS += --with-os-version=""
$(PKG)_CONFIGURE_OPTIONS += --with-os-url="http://freetz.org"

ifeq ($(strip $(FREETZ_PACKAGE_MINIDLNA_STATIC)),y)
# sqlite
$(PKG)_EXTRA_LIBS += -ldl
# libavformat
$(PKG)_EXTRA_LIBS += -lavcodec -lavutil $(if $(FREETZ_PACKAGE_FFMPEG_DECODER_libopenjpeg),-lopenjpeg) -lz -lm
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINIDLNA_DIR) \
		EXTRA_CFLAGS="-ffunction-sections -fdata-sections" \
		EXTRA_LDFLAGS="-Wl,--gc-sections" \
		EXTRA_LIBS="$(MINIDLNA_EXTRA_LIBS)" \
		V=1

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
