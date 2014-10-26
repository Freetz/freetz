FIND_SQUASHFS_SRC:=$(TOOLS_DIR)/make/find-squashfs/src
FIND_SQUASHFS_DIR:=$(TOOLS_SOURCE_DIR)/find-squashfs

find-squashfs-unpacked: $(FIND_SQUASHFS_DIR)/.unpacked
$(FIND_SQUASHFS_DIR)/.unpacked: $(wildcard $(FIND_SQUASHFS_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(FIND_SQUASHFS_DIR)
	mkdir -p $(FIND_SQUASHFS_DIR)
	$(call COPY_USING_TAR,$(FIND_SQUASHFS_SRC),$(FIND_SQUASHFS_DIR))
	touch $@

$(FIND_SQUASHFS_DIR)/find-squashfs: $(FIND_SQUASHFS_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" -C $(FIND_SQUASHFS_DIR)

$(TOOLS_DIR)/find-squashfs: $(FIND_SQUASHFS_DIR)/find-squashfs
	$(INSTALL_FILE)

find-squashfs: $(TOOLS_DIR)/find-squashfs

find-squashfs-clean:
	-$(MAKE) -C $(FIND_SQUASHFS_DIR) clean

find-squashfs-dirclean:
	$(RM) -r $(FIND_SQUASHFS_DIR)

find-squashfs-distclean: find-squashfs-dirclean
	$(RM) $(TOOLS_DIR)/find-squashfs
