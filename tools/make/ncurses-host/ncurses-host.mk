$(call TOOLS_INIT, 6.3)
$(PKG)_SOURCE:=ncurses-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059
$(PKG)_SITE:=@GNU/ncurses


$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(NCURSES_HOST_SOURCE) $(NCURSES_HOST_SITE) $(NCURSES_HOST_SOURCE_SHA256)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(NCURSES_HOST_SOURCE)
	$(call APPLY_PATCHES,$(NCURSES_HOST_MAKE_DIR)/patches,$(NCURSES_HOST_DIR))
	touch $@

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
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

$($(PKG)_DIR)/progs/tic: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(NCURSES_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/tic: $($(PKG)_DIR)/progs/tic
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/tic


$(pkg)-clean:
	-$(MAKE) -C $(NCURSES_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(NCURSES_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/tic

$(TOOLS_FINISH)
