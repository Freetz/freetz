$(call TOOL_INIT, 1.34.1)
$(TOOL)_SOURCE:=busybox-$($(TOOL)_VERSION).tar.bz2
$(TOOL)_SOURCE_SHA256:=415fbd89e5344c96acf449d94a6f956dbed62e18e835fc83e064db33a34bd549
$(TOOL)_SITE:=https://www.busybox.net/downloads

$(TOOL)_BINARY:=$($(TOOL)_DIR)/busybox
$(TOOL)_CONFIG_FILE:=$($(TOOL)_MAKE_DIR)/Config.busybox
$(TOOL)_TARGET_DIR:=$(TOOLS_DIR)
$(TOOL)_TARGET_BINARY:=$(TOOLS_DIR)/busybox
$(TOOL)_DEPENDS:=tar-host


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(BUSYBOX_HOST_SOURCE) $(BUSYBOX_HOST_SITE) $(BUSYBOX_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $($(TOOL)_DEPENDS)
	$(TAR) -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(BUSYBOX_HOST_SOURCE)
	$(call APPLY_PATCHES,$(BUSYBOX_HOST_MAKE_DIR)/patches,$(BUSYBOX_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked $($(TOOL)_CONFIG_FILE)
	cp $(BUSYBOX_HOST_CONFIG_FILE) $(BUSYBOX_HOST_DIR)/.config
	$(TOOL_SUBMAKE) -C $(BUSYBOX_HOST_DIR) oldconfig
	touch $@

$($(TOOL)_BINARY): $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(BUSYBOX_HOST_DIR)

$($(TOOL)_TARGET_BINARY): $($(TOOL)_BINARY)
	$(INSTALL_FILE)
	find $(BUSYBOX_HOST_TARGET_DIR) -lname busybox -delete
	for i in $$($(BUSYBOX_HOST_TARGET_BINARY) --list); do \
		ln -fs busybox $(BUSYBOX_HOST_TARGET_DIR)/$$i; \
	done

$(tool)-precompiled: $(BUSYBOX_HOST_TARGET_BINARY)


$(tool)-clean:
	-$(MAKE) -C $(BUSYBOX_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(BUSYBOX_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	find $(BUSYBOX_HOST_TARGET_DIR) \( -lname busybox -o -name busybox \) -delete

$(TOOL_FINISH)
