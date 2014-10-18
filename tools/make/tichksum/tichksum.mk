TICHKSUM_SRC:=$(TOOLS_DIR)/make/tichksum/src
TICHKSUM_DIR:=$(TOOLS_SOURCE_DIR)/tichksum

tichksum-unpacked: $(TICHKSUM_DIR)/.unpacked
$(TICHKSUM_DIR)/.unpacked: $(wildcard $(TICHKSUM_SRC)/*) | $(TOOLS_SOURCE_DIR) tar-host
	$(RM) -r $(TICHKSUM_DIR)
	mkdir -p $(TICHKSUM_DIR)
	$(TAR) -C $(TICHKSUM_SRC) -c . | $(TAR) --exclude=.svn -C $(TICHKSUM_DIR) -x $(VERBOSE)
	touch $@

$(TICHKSUM_DIR)/tichksum: $(TICHKSUM_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" -C $(TICHKSUM_DIR)

$(TOOLS_DIR)/tichksum: $(TICHKSUM_DIR)/tichksum
	$(INSTALL_FILE)

tichksum: $(TOOLS_DIR)/tichksum

tichksum-clean:
	-$(MAKE) -C $(TICHKSUM_DIR) clean

tichksum-dirclean:
	$(RM) -r $(TICHKSUM_DIR)

tichksum-distclean: tichksum-dirclean
	$(RM) $(TOOLS_DIR)/tichksum
