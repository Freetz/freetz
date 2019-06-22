$(call PKG_INIT_BIN, 1204)
$(PKG)_SOURCE:=$(pkg)-r$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_CHECKSUM:=X
$(PKG)_SITE:=svn@https://ssl.bulix.org/svn/lcd4linux/trunk

$(PKG)_BINARY:=$($(PKG)_DIR)/lcd4linux
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lcd4linux

$(PKG)_DEPENDS_ON += ncurses libgd jpeg libusb libusb1 libftdi
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-x=no
$(PKG)_CONFIGURE_OPTIONS += --with-drivers=all,!DPF,!LCDLinux,!LUIse,!RouterBoard,!serdisplib,!st2205,!VNC,!X11,!HD44780,!LPH7508,!M50530,!T6963,!Noritake,!T6963,!Sample
$(PKG)_CONFIGURE_OPTIONS += --with-plugins=all,!dbus,!gps,!mpd,!mpris_dbus,!mysql,!netinfo,!qnaplog,!wireless
$(PKG)_PATCH_POST_CMDS += echo "\#define SVN_VERSION \"$($(PKG)_VERSION)M\"" > svn_version.h;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LCD4LINUX_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $(LCD4LINUX_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LCD4LINUX_DIR) clean
	$(RM) $(LCD4LINUX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(LCD4LINUX_TARGET_BINARY)

$(PKG_FINISH)
