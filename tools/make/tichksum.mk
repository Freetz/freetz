TI_CHKSUM_VERSION:=0.2
TI_CHKSUM_SOURCE:=TI-chksum-$(TI_CHKSUM_VERSION).tar.bz2
TI_CHKSUM_DIR:=$(SOURCE_DIR)/TI-chksum-$(TI_CHKSUM_VERSION)


$(TI_CHKSUM_DIR)/.unpacked: $(TOOLS_DIR)/source/$(TI_CHKSUM_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(TOOLS_DIR)/source/$(TI_CHKSUM_SOURCE)
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
