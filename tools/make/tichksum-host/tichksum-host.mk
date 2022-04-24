TICHKSUM_HOST_SRC:=$(TOOLS_DIR)/make/tichksum-host/src
TICHKSUM_HOST_DIR:=$(TOOLS_SOURCE_DIR)/tichksum


tichksum-host-unpacked: $(TICHKSUM_HOST_DIR)/.unpacked
$(TICHKSUM_HOST_DIR)/.unpacked: $(wildcard $(TICHKSUM_HOST_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(TICHKSUM_HOST_DIR)
	mkdir -p $(TICHKSUM_HOST_DIR)
	$(call COPY_USING_TAR,$(TICHKSUM_HOST_SRC),$(TICHKSUM_HOST_DIR))
	touch $@

$(TICHKSUM_HOST_DIR)/tichksum: $(TICHKSUM_HOST_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(TICHKSUM_HOST_DIR) $(QUIET)

$(TOOLS_DIR)/tichksum: $(TICHKSUM_HOST_DIR)/tichksum
	$(INSTALL_FILE)

tichksum-host-precompiled: $(TOOLS_DIR)/tichksum


tichksum-host-clean:
	-$(MAKE) -C $(TICHKSUM_HOST_DIR) clean

tichksum-host-dirclean:
	$(RM) -r $(TICHKSUM_HOST_DIR)

tichksum-host-distclean: tichksum-host-dirclean
	$(RM) $(TOOLS_DIR)/tichksum

