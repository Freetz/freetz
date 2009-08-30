$(call PKG_INIT_BIN, 1.15.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-freetz.tar.bz2
$(PKG)_SITE:=http://download.berlios.de/callmonitor
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/recode
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/callmonitor/bin/recode
$(PKG)_STARTLEVEL=30

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_ENV) -C $(CALLMONITOR_DIR)/src

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg) $(pkg)-precompiled: $($(PKG)_TARGET_DIR)/.packaged $($(PKG)_TARGET_BINARY)

$($(PKG)_TARGET_DIR)/.packaged: $(CALLMONITOR_DIR)/.configured
	mkdir -p $(CALLMONITOR_TARGET_DIR)/root
	tar -c -C $(CALLMONITOR_DIR)/root --exclude=.svn . | tar -x -C $(CALLMONITOR_DEST_DIR)
	cp $(CALLMONITOR_DIR)/.language $(CALLMONITOR_TARGET_DIR)/
	@touch $@

$(PKG_FINISH)
