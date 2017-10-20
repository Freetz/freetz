$(call PKG_INIT_BIN, 1.27.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=476186f4bab81781dab2369bfd42734e
$(PKG)_SITE:=http://www.busybox.net/downloads

$(PKG)_CONDITIONAL_PATCHES += $(call qstrip,$(FREETZ_KERNEL_VERSION_MAJOR))
$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION_MAJOR

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)

$(PKG)_TARGET_DIR:=$(subst -$($(PKG)_VERSION),,$($(PKG)_TARGET_DIR))
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg)

$(PKG)_MAKE_FLAGS += CC="$(TARGET_CC)"
$(PKG)_MAKE_FLAGS += CROSS_COMPILE="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)"
$(PKG)_MAKE_FLAGS += EXTRA_CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_MAKE_FLAGS += ARCH="$(TARGET_ARCH)"

include $(MAKE_DIR)/busybox/busybox.rebuild-subopts.mk.in

ifneq ($(strip $(DL_DIR)/$(BUSYBOX_SOURCE)), $(strip $(DL_DIR)/$(BUSYBOX_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	@cat $(TOPDIR)/.config \
		| sed -nr 's!^(# )*(FREETZ_BUSYBOX_)([^_].*)!\1CONFIG_\3!p' \
		> $(BUSYBOX_DIR)/.config ;\
	for bbsym in $$(sed -rn 's/^depends_on ([^ ]+) .*/\1/p' "$(BUSYBOX_MAKE_DIR)/generate.sh"); do \
		if ! grep -qE "(# )?CONFIG_$$bbsym[= ]" "$(BUSYBOX_DIR)/.config"; then \
			echo "# CONFIG_$$bbsym is not set" >> $(BUSYBOX_DIR)/.config ;\
		fi ;\
	done ;\
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BUSYBOX_DIR) \
		$(BUSYBOX_MAKE_FLAGS)

$($(PKG)_BINARY).links: $($(PKG)_BINARY)
	$(SUBMAKE) -C $(BUSYBOX_DIR) \
		$(BUSYBOX_MAKE_FLAGS) \
		busybox.links
	touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY).links: $($(PKG)_BINARY).links
	cat $(BUSYBOX_BINARY).links | sed -r -e 's,(blkid|wget),\1-busybox,g' > $(BUSYBOX_TARGET_BINARY).links

$(pkg)-precompiled: uclibc $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_BINARY).links

$(pkg)-clean: $(pkg)-uninstall
	-$(SUBMAKE) -C $(BUSYBOX_DIR) $(BUSYBOX_MAKE_FLAGS) clean

$(pkg)-uninstall:
	$(RM) $(BUSYBOX_TARGET_BINARY) $(BUSYBOX_TARGET_BINARY).links

$(PKG_FINISH)
