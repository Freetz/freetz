$(call TOOLS_INIT, 1.36.0)
$(PKG)_SOURCE:=busybox-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=542750c8af7cb2630e201780b4f99f3dcceeb06f505b479ec68241c1e6af61a5
$(PKG)_SITE:=https://www.busybox.net/downloads

$(PKG)_BINARY:=$($(PKG)_DIR)/busybox
$(PKG)_TARGET_DIR:=$(TOOLS_DIR)
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/busybox

$(PKG)_CONFIG_FILE:=$($(PKG)_MAKE_DIR)/Config.busybox

$(PKG)_DEPENDS_ON:=tar-host


define $(PKG)_CUSTOM_UNPACK
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$($(PKG)_SOURCE)
endef

$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/.prepared: $($(PKG)_DIR)/.configured
	cp $(BUSYBOX_HOST_CONFIG_FILE) $(BUSYBOX_HOST_DIR)/.config
	$(TOOLS_SUBMAKE) -C $(BUSYBOX_HOST_DIR) oldconfig
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.prepared
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
