$(call PKG_INIT_BIN, 1.64.6)
$(PKG)_SOURCE:=streamripper-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=c1d75f2e9c7b38fd4695be66eff4533395248132f3cc61f375196403c4d8de42
$(PKG)_SITE:=@SF/streamripper
$(PKG)_BINARY:=$($(PKG)_DIR)/streamripper
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/streamripper

$(PKG)_DEPENDS_ON += pcre glib2 libmad

$(PKG)_CONFIGURE_OPTIONS += --with-included-argv
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-curses=no
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-oggtest
$(PKG)_CONFIGURE_OPTIONS += --disable-vorbistest

ifeq ($(strip $(FREETZ_PACKAGE_STREAMRIPPER_WITH_OGGVORBIS)),y)
$(PKG)_DEPENDS_ON += libogg libvorbis

$(PKG)_CONFIGURE_OPTIONS += --with-ogg-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-ogg-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_OPTIONS += --with-vorbis-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-vorbis-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
else
$(PKG)_CONFIGURE_ENV += sr_disable_oggvorbis_support=yes
$(PKG)_CONFIGURE_OPTIONS += --without-ogg
$(PKG)_CONFIGURE_OPTIONS += --without-vorbis
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STREAMRIPPER_WITH_OGGVORBIS

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(STREAMRIPPER_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STREAMRIPPER_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STREAMRIPPER_TARGET_BINARY)

$(PKG_FINISH)
