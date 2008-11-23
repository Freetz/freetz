$(call PKG_INIT_BIN, 0.6.2)

$(PKG)_MAKE_DIR := $(MAKE_DIR)/mdev

$(PKG)_TABLES := root/etc/device.table tools/device_table.txt

# a list of devices exempt from static creation
$(PKG)_DEVICE := /dev pts misc mem kmem null zero random urandom loop ttyp ptyp ptmx
$(PKG)_DEVICE += ttyP ttyS fb psaux pts/ mtd mtdblock net net/tun coda coda/ vhci
$(PKG)_DEVICE += rfcomm sd[a-z] usblp[0-9] ttyUSB misc/fuse "tty\tc\t666\t0\t0\t5"
$(PKG)_DEVICE += shm

$(PKG)_KERNEL_VERSION := $(shell echo $(KERNEL_VERSION) | $(SED) 's/\.[^.]*$$//')

$(PKG)_DEPENDS_ON := e2fsprogs

$(PKG_UNPACKED)

$(pkg):

$($(PKG)_TARGET_DIR)/.patch_tables: $($(PKG)_TABLES)
	@for n in $(MDEV_DEVICE); do \
		for f in $(MDEV_TABLES); do \
			if echo "$$n" | grep -q '^/'; then \
				$(SED) -i "s,^\($$n[[:blank:]].*\),#\1," $$f; \
			else \
				$(SED) -i "s,^\(/dev/$$n[[:blank:]].*\),#\1," $$f; \
			fi \
		done \
	done
	@touch $@

$($(PKG)_TARGET_DIR)/.patch_model: $($(PKG)_TARGET_DIR)/.patch_tables
	@freetz_type=$$(echo $(FREETZ_TYPE_STRING) | $(SED) 's/_.*//'); \
	for f in $(MDEV_MAKE_DIR)/patches/hardware/$${freetz_type}_*.patch; do \
		if [ -r $$f ]; then \
			$(PATCH_TOOL) $(MDEV_TARGET_DIR) $$f; \
		else \
			echo unsupported model $(FREETZ_TYPE_STRING) 2>&1; \
			exit 1; \
		fi \
	done
	@touch $@

$($(PKG)_TARGET_DIR)/.patch_usbcontrol: $($(PKG)_TARGET_DIR)/.patch_model
ifeq ($(MDEV_KERNEL_VERSION), 2.6.19)
	@echo "Kernel version $(MDEV_KERNEL_VERSION) is supported."
	@touch $@
else
ifeq ($(MDEV_KERNEL_VERSION), 2.6.13)
	@echo "Kernel version $(MDEV_KERNEL_VERSION) is supported."
	@touch $@
else
	$(error Unsupported kernel version $(KERNEL_VERSION))
endif
endif

$(pkg)-precompiled: $($(PKG)_TARGET_DIR)/.patch_usbcontrol

$(pkg)-dirclean:
	@svn revert $(MDEV_TABLES)

$(PKG_FINISH)
