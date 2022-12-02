$(call PKG_INIT_BIN, 3.14)
$(PKG)_LIB_VERSION:=0.4.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=222bcca8893d7bf8a1ce207fb39ceead5233b5015623d099392e95197676c92f
$(PKG)_SITE:=http://cloud.github.com/downloads/rvoicilas/inotify-tools
### WEBSITE:=https://github.com/inotify-tools/inotify-tools
### MANPAGE:=https://github.com/inotify-tools/inotify-tools/wiki
### CHANGES:=https://github.com/inotify-tools/inotify-tools/releases
### CVSREPO:=https://github.com/inotify-tools/inotify-tools/commits/master

$(PKG)_STARTLEVEL=10

$(PKG)_INWAIT_BINARY:=$($(PKG)_DIR)/src/.libs/inotifywait
$(PKG)_INWAIT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/inotifywait

$(PKG)_INWATCH_BINARY:=$($(PKG)_DIR)/src/.libs/inotifywatch
$(PKG)_INWATCH_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/inotifywatch

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libinotifytools/src/.libs/libinotifytools.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libinotifytools.so.$($(PKG)_LIB_VERSION)

$(PKG)_CATEGORY:=Debug helpers

# fix inotify-tools packaging errors (configure.ac & aclocal.m4 have a later date than libinotifytools/src/inotifytools/inotify.h.in)
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 configure.ac aclocal.m4;

$(PKG)_CONFIGURE_ENV += LD="$(TARGET_LD)"
$(PKG)_CONFIGURE_OPTIONS += --disable-doxygen


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_INWAIT_BINARY) $($(PKG)_INWATCH_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(INOTIFY_TOOLS_DIR)
	touch $@

$($(PKG)_INWAIT_TARGET_BINARY): $($(PKG)_INWAIT_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_INWATCH_TARGET_BINARY): $($(PKG)_INWATCH_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_INWAIT_TARGET_BINARY) $($(PKG)_INWATCH_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(INOTIFY_TOOLS_DIR) clean
	$(RM) $(INOTIFY_TOOLS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(INOTIFY_TOOLS_INWAIT_TARGET_BINARY)
	$(RM) $(INOTIFY_TOOLS_INWATCH_TARGET_BINARY)
	$(RM) $(INOTIFY_TOOLS_DEST_LIBDIR)/libinotifytools*.so*

$(PKG_FINISH)
