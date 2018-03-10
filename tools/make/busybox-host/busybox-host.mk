BUSYBOX_HOST_VERSION:=1.27.2
BUSYBOX_HOST_SOURCE:=busybox-$(BUSYBOX_HOST_VERSION).tar.bz2
BUSYBOX_HOST_SOURCE_MD5:=476186f4bab81781dab2369bfd42734e
BUSYBOX_HOST_SITE:=https://web.archive.org/web/https://busybox.net/downloads

BUSYBOX_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/busybox-host
BUSYBOX_HOST_DIR:=$(TOOLS_SOURCE_DIR)/busybox-$(BUSYBOX_HOST_VERSION)
BUSYBOX_HOST_BINARY:=$(BUSYBOX_HOST_DIR)/busybox
BUSYBOX_HOST_CONFIG_FILE:=$(BUSYBOX_HOST_MAKE_DIR)/Config.busybox
BUSYBOX_HOST_TARGET_DIR:=$(TOOLS_DIR)
BUSYBOX_HOST_TARGET_BINARY:=$(TOOLS_DIR)/busybox

busybox-host-source: $(DL_DIR)/$(BUSYBOX_HOST_SOURCE)
$(DL_DIR)/$(BUSYBOX_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(BUSYBOX_HOST_SOURCE) $(BUSYBOX_HOST_SITE) $(BUSYBOX_HOST_SOURCE_MD5)

busybox-host-unpacked: $(BUSYBOX_HOST_DIR)/.unpacked
$(BUSYBOX_HOST_DIR)/.unpacked: $(DL_DIR)/$(BUSYBOX_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) tar-host
	$(TAR) -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(BUSYBOX_HOST_SOURCE)
	$(call APPLY_PATCHES,$(BUSYBOX_HOST_MAKE_DIR)/patches,$(BUSYBOX_HOST_DIR))
	touch $@

$(BUSYBOX_HOST_DIR)/.configured: $(BUSYBOX_HOST_DIR)/.unpacked $(BUSYBOX_HOST_CONFIG_FILE)
	cp $(BUSYBOX_HOST_CONFIG_FILE) $(BUSYBOX_HOST_DIR)/.config
	$(MAKE) -C $(BUSYBOX_HOST_DIR) oldconfig
	touch $@

$(BUSYBOX_HOST_BINARY): $(BUSYBOX_HOST_DIR)/.configured
	$(MAKE) -C $(BUSYBOX_HOST_DIR)

$(BUSYBOX_HOST_TARGET_BINARY): $(BUSYBOX_HOST_BINARY)
	$(INSTALL_FILE)
	find $(BUSYBOX_HOST_TARGET_DIR) -lname busybox -delete
	for i in $$($(BUSYBOX_HOST_TARGET_BINARY) --list); do \
		ln -fs busybox $(BUSYBOX_HOST_TARGET_DIR)/$$i; \
	done

busybox-host: $(BUSYBOX_HOST_TARGET_BINARY)

busybox-host-clean:
	-$(MAKE) -C $(BUSYBOX_HOST_DIR) clean

busybox-host-dirclean:
	$(RM) -r $(BUSYBOX_HOST_DIR)

busybox-host-distclean: busybox-host-dirclean
	find $(BUSYBOX_HOST_TARGET_DIR) \( -lname busybox -o -name busybox \) -delete
