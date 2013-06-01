$(call PKG_INIT_BIN, 11.4.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=8ec0d10834c87a2bff58f23d961c67f16a26d01a
$(PKG)_SITE:=http://downloads.asterisk.org/pub/telephony/asterisk/releases

$(PKG)_INSTALL_SUBDIR:=_install

$(PKG)_BINARY_BUILD_DIR  := $($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)/usr/sbin/asterisk
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/sbin/asterisk

$(PKG)_MODULE_BUILD_DIR  := $($(PKG)_DIR)/$($(PKG)_INSTALL_SUBDIR)/usr/lib/asterisk/modules/chan_iax2.so
$(PKG)_MODULE_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/lib/asterisk/modules/chan_iax2.so

$(PKG)_DEPENDS_ON += curl
$(PKG)_DEPENDS_ON += libgsm
$(PKG)_DEPENDS_ON += ncurses
#$(PKG)_DEPENDS_ON += openssl
$(PKG)_DEPENDS_ON += pjproject2
$(PKG)_DEPENDS_ON += popt
$(PKG)_DEPENDS_ON += speex
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_DEPENDS_ON += srtp
$(PKG)_DEPENDS_ON += zlib

# Remove internal pjproject version to ensure that it is not used.
# We use pjproject version modified by asterisk developers (contains shared libraries support).
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r res/pjproject;

$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-xmldoc
$(PKG)_CONFIGURE_OPTIONS += --disable-asteriskssl

$(PKG)_CONFIGURE_OPTIONS += --with-asound=no
$(PKG)_CONFIGURE_OPTIONS += --with-avcodec=no
$(PKG)_CONFIGURE_OPTIONS += --with-bfd=no
$(PKG)_CONFIGURE_OPTIONS += --with-bluetooth=no
$(PKG)_CONFIGURE_OPTIONS += --with-cap=no
$(PKG)_CONFIGURE_OPTIONS += --with-cpg=no
$(PKG)_CONFIGURE_OPTIONS += --with-crypto=no
$(PKG)_CONFIGURE_OPTIONS += --with-curses=no
$(PKG)_CONFIGURE_OPTIONS += --with-dahdi=no
$(PKG)_CONFIGURE_OPTIONS += --with-execinfo=no
$(PKG)_CONFIGURE_OPTIONS += --with-gmime=no
$(PKG)_CONFIGURE_OPTIONS += --with-gsm="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-gtk2=no
$(PKG)_CONFIGURE_OPTIONS += --with-h323=no
$(PKG)_CONFIGURE_OPTIONS += --with-hoard=no
$(PKG)_CONFIGURE_OPTIONS += --with-ical=no
$(PKG)_CONFIGURE_OPTIONS += --with-iconv=no
$(PKG)_CONFIGURE_OPTIONS += --with-iksemel=no
$(PKG)_CONFIGURE_OPTIONS += --with-ilbc=no
$(PKG)_CONFIGURE_OPTIONS += --with-imap=no
$(PKG)_CONFIGURE_OPTIONS += --with-inotify=no
$(PKG)_CONFIGURE_OPTIONS += --with-iodbc=no
$(PKG)_CONFIGURE_OPTIONS += --with-isdnnet=no
$(PKG)_CONFIGURE_OPTIONS += --with-jack=no
$(PKG)_CONFIGURE_OPTIONS += --with-kqueue=no
$(PKG)_CONFIGURE_OPTIONS += --with-ldap=no
$(PKG)_CONFIGURE_OPTIONS += --with-libcurl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
#$(PKG)_CONFIGURE_OPTIONS += --with-libedit=no # use internal libedit
$(PKG)_CONFIGURE_OPTIONS += --with-libxml2=no
$(PKG)_CONFIGURE_OPTIONS += --with-ltdl=no
$(PKG)_CONFIGURE_OPTIONS += --with-lua=no
$(PKG)_CONFIGURE_OPTIONS += --with-misdn=no
$(PKG)_CONFIGURE_OPTIONS += --with-mysqlclient=no
$(PKG)_CONFIGURE_OPTIONS += --with-nbs=no
$(PKG)_CONFIGURE_OPTIONS += --with-ncurses="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-neon29=no
$(PKG)_CONFIGURE_OPTIONS += --with-neon=no
$(PKG)_CONFIGURE_OPTIONS += --with-netsnmp=no
$(PKG)_CONFIGURE_OPTIONS += --with-newt=no
$(PKG)_CONFIGURE_OPTIONS += --with-ogg=no
$(PKG)_CONFIGURE_OPTIONS += --with-openr2=no
$(PKG)_CONFIGURE_OPTIONS += --with-osptk=no
$(PKG)_CONFIGURE_OPTIONS += --with-oss=no
$(PKG)_CONFIGURE_OPTIONS += --with-popt="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-portaudio=no
$(PKG)_CONFIGURE_OPTIONS += --with-postgres=no
$(PKG)_CONFIGURE_OPTIONS += --with-pri=no
$(PKG)_CONFIGURE_OPTIONS += --with-pwlib=no
$(PKG)_CONFIGURE_OPTIONS += --with-radius=no
$(PKG)_CONFIGURE_OPTIONS += --with-resample=no
$(PKG)_CONFIGURE_OPTIONS += --with-SDL_image=no
$(PKG)_CONFIGURE_OPTIONS += --with-sdl=no
$(PKG)_CONFIGURE_OPTIONS += --with-sounds-cache=no
$(PKG)_CONFIGURE_OPTIONS += --with-spandsp=no
$(PKG)_CONFIGURE_OPTIONS += --with-speexdsp="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-speex="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite3="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite=no
$(PKG)_CONFIGURE_OPTIONS += --with-srtp="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-ss7=no
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=no
$(PKG)_CONFIGURE_OPTIONS += --with-suppserv=no
$(PKG)_CONFIGURE_OPTIONS += --with-tds=no
$(PKG)_CONFIGURE_OPTIONS += --with-termcap=no
$(PKG)_CONFIGURE_OPTIONS += --with-timerfd=no
$(PKG)_CONFIGURE_OPTIONS += --with-tinfo=no
$(PKG)_CONFIGURE_OPTIONS += --with-tonezone=no
$(PKG)_CONFIGURE_OPTIONS += --with-unixodbc=no
$(PKG)_CONFIGURE_OPTIONS += --with-vorbis=no
$(PKG)_CONFIGURE_OPTIONS += --with-vpb=no
$(PKG)_CONFIGURE_OPTIONS += --with-x11=no
$(PKG)_CONFIGURE_OPTIONS += --with-z="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG)_MAKE_OPTIONS += -C $(ASTERISK_DIR)
$(PKG)_MAKE_OPTIONS += NOISY_BUILD=yes
$(PKG)_MAKE_OPTIONS += DEBUG=""
$(PKG)_MAKE_OPTIONS += OPTIMIZE=""
$(PKG)_MAKE_OPTIONS += ASTCFLAGS="-fno-strict-aliasing -DLOW_MEMORY"
$(PKG)_MAKE_OPTIONS += PJPROJECT_BUILD_MAK_DIR="$(abspath $(PJPROJECT2_DIR))"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(ASTERISK_MAKE_OPTIONS)
	touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(SUBMAKE) $(ASTERISK_MAKE_OPTIONS) \
		DESTDIR="$(abspath $(ASTERISK_DIR)/$(ASTERISK_INSTALL_SUBDIR))" \
		install samples
	touch $@

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_MODULE_BUILD_DIR): $($(PKG)_DIR)/.installed

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULE_TARGET_DIR): $($(PKG)_MODULE_BUILD_DIR)
	mkdir -p $(dir $@)
	cp -a $(dir $<)/*.so $(dir $@)
	-$(TARGET_STRIP) $(dir $@)/*.so
	touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_MODULE_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) $(ASTERISK_MAKE_OPTIONS) distclean
	$(RM) $(ASTERISK_DIR)/{.configured,.compiled,.installed}

$(pkg)-uninstall:
	$(RM) -r \
		$(ASTERISK_BINARY_TARGET_DIR) \
		$(ASTERISK_DEST_DIR)/usr/lib/asterisk/modules

$(PKG_FINISH)
