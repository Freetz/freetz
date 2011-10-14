KCONFIG_VERSION:=2.6.39
KCONFIG_SOURCE_TMP:=kconfig-sa-$(KCONFIG_VERSION)
KCONFIG_SOURCE:=$(KCONFIG_SOURCE_TMP).tar.gz
KCONFIG_SOURCE_MD5:=609c3981f2466620ee42fe0bfa33388b
KCONFIG_SITE:=https://github.com/lacombar/kconfig/tarball
KCONFIG_DIR:=$(TOOLS_SOURCE_DIR)/lacombar-kconfig-03a72ba
KCONFIG_MAKE_DIR:=$(TOOLS_DIR)/make
KCONFIG_TARGET_DIR:=$(TOOLS_DIR)/config
KCONFIG_HOSTCFLAGS=-Wall -Wno-char-subscripts -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -DCONFIG_=\"\"

$(DL_DIR)/$(KCONFIG_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(KCONFIG_SOURCE_TMP) $(KCONFIG_SITE) $(KCONFIG_SOURCE_MD5)
	mv "$(DL_DIR)/$(KCONFIG_SOURCE_TMP)" "$(DL_DIR)/$(KCONFIG_SOURCE)"

kconfig-source: $(DL_DIR)/$(KCONFIG_SOURCE)

$(KCONFIG_DIR)/.unpacked: $(DL_DIR)/$(KCONFIG_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(KCONFIG_SOURCE); \
	mv $(KCONFIG_DIR)/scripts/kconfig/lex.zconf.c_shipped $(KCONFIG_DIR)/scripts/kconfig/zconf.lex.c_shipped; \
	rm $(KCONFIG_DIR)/scripts/kconfig/kconfig_load.c; \
	for i in $(KCONFIG_MAKE_DIR)/patches/*.kconfig.patch; do \
		$(PATCH_TOOL) $(KCONFIG_DIR) $$i; \
	done; \
	touch $@
	find $(KCONFIG_DIR) > find_kconfig_before

$(KCONFIG_DIR)/scripts/kconfig/conf: $(KCONFIG_DIR)/.unpacked
	$(MAKE) -C $(KCONFIG_DIR) HOSTCFLAGS='$(KCONFIG_HOSTCFLAGS)' config

$(KCONFIG_DIR)/scripts/kconfig/mconf: $(KCONFIG_DIR)/.unpacked
	$(MAKE) -C $(KCONFIG_DIR) HOSTCFLAGS='$(KCONFIG_HOSTCFLAGS)' menuconfig

$(KCONFIG_TARGET_DIR)/conf: $(KCONFIG_DIR)/scripts/kconfig/conf
	cp $(KCONFIG_DIR)/scripts/kconfig/conf $(KCONFIG_TARGET_DIR)/conf

$(KCONFIG_TARGET_DIR)/mconf: $(KCONFIG_DIR)/scripts/kconfig/mconf
	cp $(KCONFIG_DIR)/scripts/kconfig/mconf $(KCONFIG_TARGET_DIR)/mconf

kconfig: $(KCONFIG_TARGET_DIR)/conf $(KCONFIG_TARGET_DIR)/mconf

kconfig-clean:
	$(RM) \
		$(KCONFIG_DIR)/scripts/basic/.*.cmd \
		$(KCONFIG_DIR)/scripts/kconfig/.*.cmd \
		$(KCONFIG_DIR)/scripts/kconfig/lxdialog/.*.cmd \
		$(KCONFIG_DIR)/scripts/kconfig/*.o \
		$(KCONFIG_DIR)/scripts/kconfig/lxdialog/*.o \
		$(KCONFIG_DIR)/scripts/kconfig/zconf.*.c \
		$(KCONFIG_DIR)/scripts/basic/fixdep \
		$(KCONFIG_DIR)/scripts/kconfig/conf \
		$(KCONFIG_DIR)/scripts/kconfig/mconf
	find $(KCONFIG_DIR) > find_kconfig_after

kconfig-dirclean:
	$(RM) -r $(KCONFIG_DIR)

kconfig-distclean:
	$(RM) \
		$(KCONFIG_TARGET_DIR)/conf \
		$(KCONFIG_TARGET_DIR)/mconf
