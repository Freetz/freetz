FIND_SQUASHFS_HOST_SRC:=$(TOOLS_DIR)/make/find-squashfs-host/src
FIND_SQUASHFS_HOST_DIR:=$(TOOLS_SOURCE_DIR)/find-squashfs


find-squashfs-host-unpacked: $(FIND_SQUASHFS_HOST_DIR)/.unpacked
$(FIND_SQUASHFS_HOST_DIR)/.unpacked: $(wildcard $(FIND_SQUASHFS_HOST_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(FIND_SQUASHFS_HOST_DIR)
	mkdir -p $(FIND_SQUASHFS_HOST_DIR)
	$(call COPY_USING_TAR,$(FIND_SQUASHFS_HOST_SRC),$(FIND_SQUASHFS_HOST_DIR))
	touch $@

$(FIND_SQUASHFS_HOST_DIR)/find-squashfs: $(FIND_SQUASHFS_HOST_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(FIND_SQUASHFS_HOST_DIR)

$(TOOLS_DIR)/find-squashfs: $(FIND_SQUASHFS_HOST_DIR)/find-squashfs
	$(INSTALL_FILE)

find-squashfs-host-precompiled: $(TOOLS_DIR)/find-squashfs


find-squashfs-host-clean:
	-$(MAKE) -C $(FIND_SQUASHFS_HOST_DIR) clean

find-squashfs-host-dirclean:
	$(RM) -r $(FIND_SQUASHFS_HOST_DIR)

find-squashfs-host-distclean: find-squashfs-host-dirclean
	$(RM) $(TOOLS_DIR)/find-squashfs

