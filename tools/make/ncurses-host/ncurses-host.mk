NCURSES_HOST_VERSION:=6.2
NCURSES_HOST_SOURCE:=ncurses-$(NCURSES_HOST_VERSION).tar.gz
NCURSES_HOST_SOURCE_SHA256:=30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d
NCURSES_HOST_SITE:=@GNU/ncurses

NCURSES_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/ncurses-host
NCURSES_HOST_DIR:=$(TOOLS_SOURCE_DIR)/ncurses-$(NCURSES_HOST_VERSION)

ncurses-host-source: $(DL_DIR)/$(NCURSES_HOST_SOURCE)
$(DL_DIR)/$(NCURSES_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(NCURSES_HOST_SOURCE) $(NCURSES_HOST_SITE) $(NCURSES_HOST_SOURCE_SHA256)

ncurses-host-unpacked: $(NCURSES_HOST_DIR)/.unpacked
$(NCURSES_HOST_DIR)/.unpacked: $(DL_DIR)/$(NCURSES_HOST_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(NCURSES_HOST_SOURCE)
	$(call APPLY_PATCHES,$(NCURSES_HOST_MAKE_DIR)/patches,$(NCURSES_HOST_DIR))
	touch $@

$(NCURSES_HOST_DIR)/.configured: $(NCURSES_HOST_DIR)/.unpacked
	(cd $(NCURSES_HOST_DIR); $(RM) config.cache; \
		CFLAGS="-Wall -O2" \
		CC="$(TOOLS_CC)" \
		./configure \
		\
		\
		$(DISABLE_NLS) \
		$(QUIET) \
	);
	touch $@

$(NCURSES_HOST_DIR)/progs/tic: $(NCURSES_HOST_DIR)/.configured
	$(MAKE) -C $(NCURSES_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/tic: $(NCURSES_HOST_DIR)/progs/tic
	$(INSTALL_FILE)

ncurses-host: $(TOOLS_DIR)/tic

ncurses-host-clean:
	-$(MAKE) -C $(NCURSES_HOST_DIR) clean

ncurses-host-dirclean:
	$(RM) -r $(NCURSES_HOST_DIR)

ncurses-host-distclean: ncurses-host-dirclean
	$(RM) $(TOOLS_DIR)/tic
