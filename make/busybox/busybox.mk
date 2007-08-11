BUSYBOX_MAKE_DIR:=$(MAKE_DIR)/busybox
BUSYBOX_REF_DIR:=$(SOURCE_DIR)/ref-$(BUSYBOX_REF)

#ifeq ($(strip $(DS_BUSYBOX_SNAPSHOT)),y)
#BUSYBOX_VERSION:=snapshot
#BUSYBOX_DIR:=$(BUSYBOX_REF_DIR)/$(SOURCE_DIR)/busybox
#BUSYBOX_CONFIG_FILE:=$(BUSYBOX_MAKE_DIR)/Config.snapshot
#else
BUSYBOX_VERSION:=1.2.1
BUSYBOX_DIR:=$(BUSYBOX_REF_DIR)/busybox-$(BUSYBOX_VERSION)
BUSYBOX_CONFIG_FILE:=$(BUSYBOX_MAKE_DIR)/Config.$(BUSYBOX_REF)
#endif

BUSYBOX_SOURCE:=busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_SITE:=http://www.busybox.net/downloads
BUSYBOX_TARGET_DIR:=busybox
BUSYBOX_TARGET_BINARY:=busybox


$(DL_DIR)/$(BUSYBOX_SOURCE):
	wget -P $(DL_DIR) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

$(BUSYBOX_DIR)/.unpacked: $(DL_DIR)/$(BUSYBOX_SOURCE)
	mkdir -p $(BUSYBOX_REF_DIR)
	tar -C $(BUSYBOX_REF_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BUSYBOX_SOURCE)
	for i in $(BUSYBOX_MAKE_DIR)/patches/*.patch; do \
		patch -d $(BUSYBOX_DIR) -p0 < $$i; \
	done
	touch $@

$(BUSYBOX_DIR)/.configured: $(BUSYBOX_DIR)/.unpacked $(BUSYBOX_CONFIG_FILE)
	cp $(BUSYBOX_CONFIG_FILE) $(BUSYBOX_DIR)/.config
	sed -i -e "s,^CROSS.*,CROSS=$(TARGET_MAKE_PATH)/$(TARGET_CROSS),g" \
		$(BUSYBOX_DIR)/Rules.mak
ifeq ($(strip $(DS_TARGET_LFS)),y)
	sed -i -e 's,^.*CONFIG_LFS.*,CONFIG_LFS=y,g' $(BUSYBOX_DIR)/.config
else
	sed -i -e 's,^.*CONFIG_LFS.*,CONFIG_LFS=n,g' $(BUSYBOX_DIR)/.config
endif
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		-C $(BUSYBOX_DIR) oldconfig
	touch $@

$(BUSYBOX_DIR)/$(BUSYBOX_TARGET_BINARY): $(BUSYBOX_DIR)/.configured
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-static-libgcc" \
		-C $(BUSYBOX_DIR)

busybox-source: $(BUSYBOX_DIR)/.unpacked

busybox-menuconfig: $(BUSYBOX_DIR)/.unpacked $(BUSYBOX_CONFIG_FILE)
	cp $(BUSYBOX_CONFIG_FILE) $(BUSYBOX_DIR)/.config
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-static-libgcc" \
		-C $(BUSYBOX_DIR) menuconfig
	cp $(BUSYBOX_DIR)/.config $(BUSYBOX_CONFIG_FILE)

busybox-precompiled: $(BUSYBOX_DIR)/$(BUSYBOX_TARGET_BINARY)
	$(TARGET_STRIP) $(BUSYBOX_DIR)/$(BUSYBOX_TARGET_BINARY)
	cp $(BUSYBOX_DIR)/$(BUSYBOX_TARGET_BINARY) $(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF)
	cp $(BUSYBOX_DIR)/busybox.links $(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF).links

busybox-clean:
	-$(MAKE) -C $(BUSYBOX_DIR) clean
	rm -f $(SOURCE_DIR)/depmod.pl

busybox-dirclean:
	rm -rf $(BUSYBOX_DIR)

$(SOURCE_DIR)/depmod.pl: $(BUSYBOX_DIR)/.unpacked
	cp $(BUSYBOX_DIR)/examples/depmod.pl $@

.PHONY: busybox-menuconfig
