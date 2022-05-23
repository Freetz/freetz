$(call TOOLS_INIT, 1.34.1)
$(PKG)_SOURCE:=busybox-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA256:=415fbd89e5344c96acf449d94a6f956dbed62e18e835fc83e064db33a34bd549
$(PKG)_SITE:=https://www.busybox.net/downloads

$(PKG)_BINARY:=$($(PKG)_DIR)/busybox
$(PKG)_CONFIG_FILE:=$($(PKG)_MAKE_DIR)/Config.busybox
$(PKG)_TARGET_DIR:=$(TOOLS_DIR)
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/busybox

$(PKG)_DEPENDS_ON:=tar-host


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(BUSYBOX_HOST_SOURCE) $(BUSYBOX_HOST_SITE) $(BUSYBOX_HOST_SOURCE_SHA256)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR)
	$(TAR) -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(BUSYBOX_HOST_SOURCE)
	$(call APPLY_PATCHES,$(BUSYBOX_HOST_MAKE_DIR)/patches,$(BUSYBOX_HOST_DIR))
	touch $@

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked $($(PKG)_CONFIG_FILE)
	cp $(BUSYBOX_HOST_CONFIG_FILE) $(BUSYBOX_HOST_DIR)/.config
	$(TOOLS_SUBMAKE) -C $(BUSYBOX_HOST_DIR) oldconfig
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(BUSYBOX_HOST_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)
	find $(BUSYBOX_HOST_TARGET_DIR) -lname busybox -delete
	for i in $$($(BUSYBOX_HOST_TARGET_BINARY) --list); do \
		ln -fs busybox $(BUSYBOX_HOST_TARGET_DIR)/$$i; \
	done

$(pkg)-precompiled: $(BUSYBOX_HOST_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(BUSYBOX_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(BUSYBOX_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	find $(BUSYBOX_HOST_TARGET_DIR) \( -lname busybox -o -name busybox \) -delete

$(TOOLS_FINISH)
