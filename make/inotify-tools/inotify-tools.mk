$(call PKG_INIT_BIN, 3.13)
$(PKG)_LIB_VERSION:=0.4.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/inotify-tools
$(PKG)_INWAIT_BINARY:=$($(PKG)_DIR)/src/.libs/inotifywait
$(PKG)_INWATCH_BINARY:=$($(PKG)_DIR)/src/.libs/inotifywatch
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libinotifytools/src/.libs/libinotifytools.so.$($(PKG)_LIB_VERSION)
$(PKG)_INWAIT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/inotifywait
$(PKG)_INWATCH_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/inotifywatch
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/libinotifytools.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_ENV += LD="$(TARGET_LD)"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_INWAIT_BINARY) $($(PKG)_INWATCH_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(INOTIFY_TOOLS_DIR)
	touch $@

$($(PKG)_INWAIT_TARGET_BINARY): $($(PKG)_INWAIT_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_INWATCH_TARGET_BINARY): $($(PKG)_INWATCH_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_BINARY)
	mkdir -p $(dir $@)
	cp -a $(INOTIFY_TOOLS_DIR)/libinotifytools/src/.libs/libinotifytools.so* $(INOTIFY_TOOLS_TARGET_DIR)/root/usr/lib/
	$(TARGET_STRIP) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_INWAIT_TARGET_BINARY) \
		$($(PKG)_INWATCH_TARGET_BINARY) \
		$($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(INOTIFY_TOOLS_DIR) clean
	rm -f $(INOTIFY_TOOLS_DIR)/.compiled

$(pkg)-uninstall:
	rm -f $(INOTIFY_TOOLS_INWAIT_TARGET_BINARY)
	rm -f $(INOTIFY_TOOLS_INWATCH_TARGET_BINARY)
	rm -f $(INOTIFY_TOOLS_TARGET_DIR)/root/usr/lib/libinotifytools.so*

$(PKG_FINISH)
