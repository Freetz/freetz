SSTRIP_SRC:=$(TOOLS_DIR)/make/sstrip/src
SSTRIP_DIR:=$(TOOLS_SOURCE_DIR)/sstrip

$(SSTRIP_DIR)/.unpacked: $(wildcard $(SSTRIP_SRC)/*) | $(TOOLS_SOURCE_DIR)
	$(RM) -r $(SSTRIP_DIR)
	mkdir -p $(SSTRIP_DIR)
	tar -C $(SSTRIP_SRC) -c . | tar --exclude=.svn -C $(SSTRIP_DIR) -x $(VERBOSE)
	touch $@

$(SSTRIP_DIR)/sstrip: $(SSTRIP_DIR)/.unpacked
	$(MAKE) -C $(SSTRIP_DIR) \
		CC="$(TOOLS_CC)" \
		all

$(TOOLS_DIR)/sstrip: $(SSTRIP_DIR)/sstrip
	$(INSTALL_FILE)

sstrip: $(TOOLS_DIR)/sstrip

sstrip-source: $(SSTRIP_DIR)/.unpacked

sstrip-clean:
	-$(MAKE) -C $(SSTRIP_DIR) clean

sstrip-dirclean:
	$(RM) -r $(SSTRIP_DIR)

sstrip-distclean: sstrip-dirclean
	$(RM) $(TOOLS_DIR)/sstrip
