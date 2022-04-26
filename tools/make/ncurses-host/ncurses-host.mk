$(call TOOL_INIT, 6.3)
$(TOOL)_SOURCE:=ncurses-$($(TOOL)_VERSION).tar.gz
$(TOOL)_SOURCE_SHA256:=97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059
$(TOOL)_SITE:=@GNU/ncurses


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(NCURSES_HOST_SOURCE) $(NCURSES_HOST_SITE) $(NCURSES_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(NCURSES_HOST_SOURCE)
	$(call APPLY_PATCHES,$(NCURSES_HOST_MAKE_DIR)/patches,$(NCURSES_HOST_DIR))
	touch $@

$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(NCURSES_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		\
		\
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@

$($(TOOL)_DIR)/progs/tic: $($(TOOL)_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(NCURSES_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/tic: $($(TOOL)_DIR)/progs/tic
	$(INSTALL_FILE)

$(tool)-precompiled: $(TOOLS_DIR)/tic


$(tool)-clean:
	-$(MAKE) -C $(NCURSES_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(NCURSES_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) $(TOOLS_DIR)/tic

$(TOOL_FINISH)
