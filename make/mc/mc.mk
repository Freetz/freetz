$(call PKG_INIT_BIN, 4.6.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ec92966f4d0c8b50c344fe901859ae2a
$(PKG)_SITE:=http://www.midnight-commander.org/downloads

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mc.bin
$(PKG)_HELP:=$($(PKG)_MAKE_DIR)/files/root/usr/share/mc/mc.hlp
$(PKG)_TARGET_HELP:=$($(PKG)_DEST_DIR)/usr/share/mc/mc.hlp
ifneq ($(strip $(FREETZ_PACKAGE_MC_ONLINE_HELP)),y)
$(PKG)_NOT_INCLUDED:=$($(PKG)_TARGET_HELP)
endif

$(PKG)_DEPENDS_ON := ncurses-terminfo
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
$(PKG)_LIBS:=-liconv
else
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_LIBS:=
endif
ifeq ($(strip $(FREETZ_PACKAGE_MC_FORCE_GLIB12)),y)
$(PKG)_DEPENDS_ON += glib
else
$(PKG)_DEPENDS_ON += glib2
endif
ifeq ($(strip $(FREETZ_PACKAGE_MC_WITH_NCURSES)),y)
$(PKG)_DEPENDS_ON += ncurses
endif

$(PKG)_CONFIGURE_ENV += mc_cv_have_zipinfo=yes

$(PKG)_CONFIGURE_OPTIONS += \
		--disable-charset \
		--disable-background \
		--disable-gcc-warnings \
		--disable-glibtest \
		$(if $(FREETZ_PACKAGE_MC_FORCE_GLIB12),--with-glib12,--without-glib12) \
		--without-x \
		$(if $(FREETZ_PACKAGE_MC_VFS),--with-vfs,--without-vfs) \
		--without-mcfs \
		--without-samba \
		--with-configdir=/etc \
		--without-ext2undel \
		--without-terminfo \
		--without-termcap \
		--without-slang \
		$(if $(FREETZ_PACKAGE_MC_SUBSHELL),--with-subshell,--without-subshell) \
		$(if $(FREETZ_PACKAGE_MC_WITH_NCURSES),--with-screen=ncurses,--with-screen=mcslang) \
		$(if $(FREETZ_PACKAGE_MC_INTERNAL_EDITOR),--with-edit,--without-edit)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MC_INTERNAL_EDITOR
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MC_SUBSHELL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MC_WITH_NCURSES
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MC_FORCE_GLIB12
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MC_VFS

# Workaround mc's packaging problems. Note that this code is mc-4.6.2 specific.
# Revise it (remove if necessary) if you're about to update mc to a newer version.
$(PKG)_CONFIGURE_PRE_CMDS += \
	if which automake-1.10 >/dev/null 2>&1; then \
		: do nothing; \
	elif which automake-1.11 >/dev/null 2>&1; then \
		for f in config.guess config.sub depcomp install-sh missing; do \
			ln -sf /usr/share/automake-1.11/$$$$f $(abspath $($(PKG)_DIR)/config)/; \
		done; \
	else \
		$(call ERROR,1,automake 1.10.x or 1.11.x is required in order to build Midnight Commander. Please install one of these versions.) \
	fi;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MC_DIR) \
		LIBICONV="$(MC_LIBS)" \
		$(if $(FREETZ_PACKAGE_MC_FORCE_GLIB12),GLIB_CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/glib-1.2" GLIB_LIBS="-lglib",)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_HELP): $($(PKG)_HELP)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_MC_ONLINE_HELP),$($(PKG)_TARGET_HELP))

$(pkg)-clean:
	-$(SUBMAKE) -C $(MC_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MC_TARGET_BINARY) $(MC_TARGET_HELP)

$(PKG_FINISH)
