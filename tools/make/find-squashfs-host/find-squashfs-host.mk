$(call TOOL_INIT, 0)


$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(wildcard $($(TOOL)_SRC)/*) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(FIND_SQUASHFS_HOST_DIR)
	mkdir -p $(FIND_SQUASHFS_HOST_DIR)
	$(call COPY_USING_TAR,$(FIND_SQUASHFS_HOST_SRC),$(FIND_SQUASHFS_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/find-squashfs: $($(TOOL)_DIR)/.unpacked
	$(TOOL_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(FIND_SQUASHFS_HOST_DIR)

$(TOOLS_DIR)/find-squashfs: $($(TOOL)_DIR)/find-squashfs
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/find-squashfs


$(tool)-clean:
	-$(MAKE) -C $(FIND_SQUASHFS_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(FIND_SQUASHFS_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/find-squashfs

$(TOOL_FINISH)
