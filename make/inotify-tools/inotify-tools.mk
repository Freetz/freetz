$(call PKG_INIT_BIN, 3.14)
$(PKG)_LIB_VERSION:=0.4.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b43d95a0fa8c45f8bab3aec9672cf30c
$(PKG)_SITE:=http://cloud.github.com/downloads/rvoicilas/inotify-tools
$(PKG)_INWAIT_BINARY:=$($(PKG)_DIR)/src/.libs/inotifywait
$(PKG)_INWATCH_BINARY:=$($(PKG)_DIR)/src/.libs/inotifywatch
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libinotifytools/src/.libs/libinotifytools.so.$($(PKG)_LIB_VERSION)
$(PKG)_INWAIT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/inotifywait
$(PKG)_INWATCH_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/inotifywatch
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libinotifytools.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_ENV += LD="$(TARGET_LD)"

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

$(pkg)-precompiled: $($(PKG)_INWAIT_TARGET_BINARY) \
		$($(PKG)_INWATCH_TARGET_BINARY) \
		$($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(INOTIFY_TOOLS_DIR) clean
	$(RM) $(INOTIFY_TOOLS_DIR)/.compiled

$(pkg)-uninstall:
	$(RM) $(INOTIFY_TOOLS_INWAIT_TARGET_BINARY)
	$(RM) $(INOTIFY_TOOLS_INWATCH_TARGET_BINARY)
	$(RM) $(INOTIFY_TOOLS_DEST_LIBDIR)/libinotifytools*.so*

$(PKG_FINISH)
