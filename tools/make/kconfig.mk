KCONFIG_VERSION:=2.6.39
KCONFIG_SOURCE_TMP:=kconfig-sa-$(KCONFIG_VERSION)
KCONFIG_SOURCE:=$(KCONFIG_SOURCE_TMP).tar.gz
KCONFIG_SOURCE_MD5:=609c3981f2466620ee42fe0bfa33388b
KCONFIG_SITE:=https://github.com/lacombar/kconfig/tarball
KCONFIG_DIR:=$(TOOLS_SOURCE_DIR)/lacombar-kconfig-03a72ba
KCONFIG_MAKE_DIR:=$(TOOLS_DIR)/make
KCONFIG_TARGET_DIR:=$(TOOLS_DIR)/config

$(DL_DIR)/$(KCONFIG_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(KCONFIG_SOURCE_TMP) $(KCONFIG_SITE) $(KCONFIG_SOURCE_MD5)
	mv "$(DL_DIR)/$(KCONFIG_SOURCE_TMP)" "$(DL_DIR)/$(KCONFIG_SOURCE)"

kconfig-source: $(DL_DIR)/$(KCONFIG_SOURCE)

$(KCONFIG_DIR)/.unpacked: $(DL_DIR)/$(KCONFIG_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(KCONFIG_SOURCE)
	touch $@

$(KCONFIG_DIR)/scripts/kconfig/conf: $(KCONFIG_DIR)/.unpacked
	$(MAKE) -C $(KCONFIG_DIR) config

$(KCONFIG_DIR)/scripts/kconfig/mconf: $(KCONFIG_DIR)/.unpacked
	$(MAKE) -C $(KCONFIG_DIR) menuconfig

$(KCONFIG_TARGET_DIR)/conf: $(KCONFIG_DIR)/scripts/kconfig/conf
	cp $(KCONFIG_DIR)/scripts/kconfig/conf $(KCONFIG_TARGET_DIR)/conf

$(KCONFIG_TARGET_DIR)/mconf: $(KCONFIG_DIR)/scripts/kconfig/mconf
	cp $(KCONFIG_DIR)/scripts/kconfig/mconf $(KCONFIG_TARGET_DIR)/mconf

kconfig: $(KCONFIG_TARGET_DIR)/conf $(KCONFIG_TARGET_DIR)/mconf

kconfig-clean:
	$(RM) $(KCONFIG_DIR)/scripts/basic/.*.cmd
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/.*.cmd
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/lxdialog/.*.cmd
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/*.o
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/lxdialog/*.o
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/zconf.tab.c
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/lex.zconf.c
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/zconf.hash.c
	$(RM) $(KCONFIG_DIR)/scripts/basic/fixdep
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/conf
	$(RM) $(KCONFIG_DIR)/scripts/kconfig/mconf

kconfig-dirclean:
	$(RM) -r $(KCONFIG_DIR)

kconfig-distclean:
	$(RM) $(KCONFIG_TARGET_DIR)/conf
	$(RM) $(KCONFIG_TARGET_DIR)/mconf
