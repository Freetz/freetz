TI_CHKSUM_SRC:=$(TOOLS_DIR)/make/tichksum/src
TI_CHKSUM_DIR:=$(TOOLS_SOURCE_DIR)/tichksum

tichksum-unpacked: $(TI_CHKSUM_DIR)/.unpacked
$(TI_CHKSUM_DIR)/.unpacked: $(wildcard $(TI_CHKSUM_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(TI_CHKSUM_DIR)
	mkdir -p $(TI_CHKSUM_DIR)
	$(TAR) -C $(TI_CHKSUM_SRC) -c . | $(TAR) --exclude=.svn -C $(TI_CHKSUM_DIR) -x $(VERBOSE)
	touch $@

$(TI_CHKSUM_DIR)/tichksum: $(TI_CHKSUM_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" -C $(TI_CHKSUM_DIR)

$(TOOLS_DIR)/tichksum: $(TI_CHKSUM_DIR)/tichksum
	$(INSTALL_FILE)

tichksum: $(TOOLS_DIR)/tichksum

tichksum-clean:
	-$(MAKE) -C $(TI_CHKSUM_DIR) clean

tichksum-dirclean:
	$(RM) -r $(TI_CHKSUM_DIR)

tichksum-distclean: tichksum-dirclean
	$(RM) $(TOOLS_DIR)/tichksum
