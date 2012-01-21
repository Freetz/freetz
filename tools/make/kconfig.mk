KCONFIG_VERSION:=3.1-rc9
KCONFIG_SOURCE:=kconfig-$(KCONFIG_VERSION).tar.gz
# Cannot check MD5 because URL produces slightly different archives even
# though unpacked contents are identical.
#KCONFIG_SOURCE_MD5:=xxx
KCONFIG_SITE:=http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=snapshot;h=0efcb507b7f49a4d022a43b7309e2146fdb13b03;sf=tgz
KCONFIG_DIR:=$(TOOLS_SOURCE_DIR)/kconfig-$(KCONFIG_VERSION)
KCONFIG_MAKE_DIR:=$(TOOLS_DIR)/make
KCONFIG_TARGET_DIR:=$(TOOLS_DIR)/config

# TODO: Replace by normal use of $(DL_TOOL) as soon as it supports saving
# files from URLs under another name with '-O'
$(DL_DIR)/$(KCONFIG_SOURCE): | $(DL_DIR)
	wget -O $(DL_DIR)/$(KCONFIG_SOURCE) "$(KCONFIG_SITE)"

kconfig-source: $(DL_DIR)/$(KCONFIG_SOURCE)

$(KCONFIG_DIR)/.unpacked: $(DL_DIR)/$(KCONFIG_SOURCE) | $(TOOLS_SOURCE_DIR)
	mkdir -p $(KCONFIG_DIR)/scripts
	tar -C $(KCONFIG_DIR)/scripts $(VERBOSE) --wildcards --strip-components=1 \
		-xf $(DL_DIR)/$(KCONFIG_SOURCE) */basic */kconfig */Makefile.{build,host,lib} */Kbuild.include
	for i in $(KCONFIG_MAKE_DIR)/patches/*.kconfig.patch; do \
		$(PATCH_TOOL) $(KCONFIG_DIR) $$i; \
	done;
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

kconfig-dirclean:
	$(RM) -r $(KCONFIG_DIR)

kconfig-distclean:
	$(RM) \
		$(KCONFIG_TARGET_DIR)/conf \
		$(KCONFIG_TARGET_DIR)/mconf
