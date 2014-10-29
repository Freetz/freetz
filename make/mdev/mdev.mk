$(call PKG_INIT_BIN, 0.6.2)
$(PKG)_SOURCE_MD5:=

# a list of devices exempt from static creation
#$(PKG)_DEVICE := /dev pts misc mem kmem null zero random urandom loop ttyp ptyp ptmx
#$(PKG)_DEVICE += ttyP ttyS fb psaux pts/ mtd mtdblock net net/tun coda coda/ vhci
#$(PKG)_DEVICE += rfcomm sd[a-z] usblp[0-9] ttyUSB misc/fuse "tty\tc\t666\t0\t0\t5"
#$(PKG)_DEVICE += shm

$(PKG)_MODPROBE_CONF:=$($(PKG)_MAKE_DIR)/files/root/etc/modprobe.conf
$(PKG)_TARGET_MODPROBE_CONF:=$($(PKG)_DEST_DIR)/etc/modprobe.conf
$(PKG)_CATEGORY:=Unstable

$(PKG)_KERNEL_VERSION := $(shell echo $(KERNEL_VERSION) | $(SED) 's/\.[^.]*$$//')

$(PKG)_DEPENDS_ON += e2fsprogs

$(PKG)_REBUILD_SUBOPTS := FREETZ_TYPE_PREFIX

$(PKG_UNPACKED)

$(pkg):

$($(PKG)_TARGET_MODPROBE_CONF): $($(PKG)_MODPROBE_CONF) \
				$(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION) \
				$(TOPDIR)/.config
	@$(INSTALL_FILE)
	@touch $@

$($(PKG)_TARGET_DIR)/.patch_model: $($(PKG)_TARGET_MODPROBE_CONF)
	@freetz_type=$$(echo $(FREETZ_TYPE_PREFIX) | $(SED) 's/_.*//'); \
	for f in $(MDEV_MAKE_DIR)/patches/hardware/$${freetz_type}_*.patch; do \
		if [ -r $$f ]; then \
			set -e; $(PATCH_TOOL) $(MDEV_TARGET_DIR) $$f; \
		else \
			echo unsupported model $(FREETZ_TYPE_PREFIX) 2>&1; \
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

$(PKG_FINISH)
