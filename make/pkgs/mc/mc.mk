$(call PKG_INIT_BIN, 4.8.28)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=e994d9be9a7172e9ac4a4ad62107921f6aa312e668b056dfe5b8bcebbaf53803
$(PKG)_SITE:=http://ftp.midnight-commander.org,ftp://ftp.midnight-commander.org/pub/midnightcommander
### WEBSITE:=http://midnight-commander.org/
### MANPAGE:=http://midnight-commander.org/wiki/doc
### CHANGES:=https://github.com/MidnightCommander/mc/blob/master/doc/NEWS
### CVSREPO:=https://github.com/MidnightCommander/mc

$(PKG)_BINARY:=$($(PKG)_DIR)/src/mc
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mc
$(PKG)_TARGET_CONS_SAVER_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/mc/cons.saver

$(PKG)_DEPENDS_ON += ncurses-terminfo glib2

$(PKG)_CONFIGURE_ENV += fu_cv_sys_stat_statfs2_bsize=yes

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MC_WITH_SLANG
ifeq ($(strip $(FREETZ_PACKAGE_MC_WITH_SLANG)),y)
$(PKG)_DEPENDS_ON += slang
$(PKG)_CONFIGURE_OPTIONS += --with-screen=slang
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MC_WITH_NCURSESW
ifeq ($(strip $(FREETZ_PACKAGE_MC_WITH_NCURSESW)),y)
$(PKG)_DEPENDS_ON += ncursesw
$(PKG)_CONFIGURE_ENV += ac_cv_search_addwstr="-lncursesw"
$(PKG)_CONFIGURE_OPTIONS += --with-screen=ncurses
$(PKG)_CONFIGURE_OPTIONS += --enable-utf8
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MC_WITH_NCURSES
ifeq ($(strip $(FREETZ_PACKAGE_MC_WITH_NCURSES)),y)
$(PKG)_DEPENDS_ON += ncurses
$(PKG)_CONFIGURE_ENV += ac_cv_search_addwstr="-lncurses"
$(PKG)_CONFIGURE_OPTIONS += --with-screen=ncurses
endif

$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_LIBICONV:=-liconv
else
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath

$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += --without-x
$(PKG)_CONFIGURE_OPTIONS += --without-gpm-mouse
$(PKG)_CONFIGURE_OPTIONS += --disable-aspell
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-dot
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen-html
$(PKG)_CONFIGURE_OPTIONS += --disable-mclib
$(PKG)_CONFIGURE_OPTIONS += --disable-tests

$(PKG)_CONFIGURE_OPTIONS += --with-search-engine=glib

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/usr/share

$(PKG)_ENDIS_OPTIONS          := background charset vfs vfs-cpio vfs-extfs vfs-ftp vfs-sfs vfs-tar vfs-fish vfs-sftp vfs-smb vfs-undelfs
$(PKG)_ENDIS_OPTIONS_ENABLED  := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_ENDIS_OPTIONS),WITH)
$(PKG)_ENDIS_OPTIONS_DISABLED := $(filter-out $($(PKG)_ENDIS_OPTIONS_ENABLED),$($(PKG)_ENDIS_OPTIONS))
$(PKG)_CONFIGURE_OPTIONS      += $(foreach option,$($(PKG)_ENDIS_OPTIONS_ENABLED),--enable-$(option))
$(PKG)_CONFIGURE_OPTIONS      += $(foreach option,$($(PKG)_ENDIS_OPTIONS_DISABLED),--disable-$(option))

$(PKG)_WITH_OPTIONS           := internal-edit diff-viewer subshell
$(PKG)_WITH_OPTIONS_YES       := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_WITH_OPTIONS),WITH)
$(PKG)_WITH_OPTIONS_NO        := $(filter-out $($(PKG)_WITH_OPTIONS_YES),$($(PKG)_WITH_OPTIONS))
$(PKG)_CONFIGURE_OPTIONS      += $(foreach option,$($(PKG)_WITH_OPTIONS_YES),--with-$(option))
$(PKG)_CONFIGURE_OPTIONS      += $(foreach option,$($(PKG)_WITH_OPTIONS_NO),--without-$(option))

$(PKG)_REBUILD_SUBOPTS += $(foreach i,$($(PKG)_ENDIS_OPTIONS) $($(PKG)_WITH_OPTIONS),FREETZ_PACKAGE_MC_WITH_$(call TOUPPER_NAME,$(i)))
$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_MC_WITH_HELP),,usr/share/mc/help/mc.hlp)
$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_MC_WITH_HELP),,usr/share/mc/hints)
$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_MC_WITH_SYNTAX),,usr/share/mc/syntax)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MC_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(MC_DIR) \
		DESTDIR="$(abspath $(MC_DEST_DIR))" \
		install
	$(TARGET_STRIP) $@ $(MC_TARGET_CONS_SAVER_BINARY)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(MC_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(MC_DEST_DIR)/usr/bin/mc* $(MC_DEST_DIR)/usr/lib/mc $(MC_DEST_DIR)/usr/share/mc

$(PKG_FINISH)
