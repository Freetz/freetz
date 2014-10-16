TI_CHKSUM_VERSION:=0.2
TI_CHKSUM_SRC:=$(TOOLS_DIR)/make/tichksum/src
TI_CHKSUM_DIR:=$(TOOLS_SOURCE_DIR)/TI-chksum-$(TI_CHKSUM_VERSION)


$(TI_CHKSUM_DIR)/.unpacked: $(wildcard $(TI_CHKSUM_SRC)/*) | $(TOOLS_SOURCE_DIR)
	$(RM) -r $(TI_CHKSUM_DIR)
	mkdir -p $(TI_CHKSUM_DIR)
	tar -C $(TI_CHKSUM_SRC) -c . | tar --exclude=.svn -C $(TI_CHKSUM_DIR) -x $(VERBOSE)
	touch $@

$(TI_CHKSUM_DIR)/tichksum: $(TI_CHKSUM_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" LD="$(TOOLS_LD)" \
		-C $(TI_CHKSUM_DIR)

$(TOOLS_DIR)/tichksum: $(TI_CHKSUM_DIR)/tichksum
	cp $(TI_CHKSUM_DIR)/tichksum $(TOOLS_DIR)/tichksum

tichksum: $(TOOLS_DIR)/tichksum

tichksum-source: $(TI_CHKSUM_DIR)/.unpacked

tichksum-clean:
	-$(MAKE) -C $(TI_CHKSUM_DIR) clean

tichksum-dirclean:
	$(RM) -r $(TI_CHKSUM_DIR)

tichksum-distclean: tichksum-dirclean
	$(RM) $(TOOLS_DIR)/tichksum
