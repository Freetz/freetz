MAKEDEVS_SOURCE:=makedevs.tar.bz2
MAKEDEVS_DIR:=$(SOURCE_DIR)/makedevs


$(MAKEDEVS_DIR)/.unpacked: $(TOOLS_DIR)/source/$(MAKEDEVS_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(TOOLS_DIR)/source/$(MAKEDEVS_SOURCE)
	touch $@

$(MAKEDEVS_DIR)/makedevs: $(MAKEDEVS_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" LD="$(TOOLS_LD) -static" \
		-C $(MAKEDEVS_DIR)

$(TOOLS_DIR)/makedevs: $(MAKEDEVS_DIR)/makedevs
	cp $(MAKEDEVS_DIR)/makedevs $(TOOLS_DIR)/makedevs

makedevs: $(TOOLS_DIR)/makedevs

makedevs-source: $(MAKEDEVS_DIR)/.unpacked

makedevs-clean:
	-$(MAKE) -C $(MAKEDEVS_DIR) clean

makedevs-dirclean:
	rm -rf $(MAKEDEVS_DIR)

makedevs-distclean: makedevs-dirclean
	rm -f $(TOOLS_DIR)/makedevs
