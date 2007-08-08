IPTABLES_VERSION:=1.3.7
IPTABLES_SOURCE:=iptables-$(IPTABLES_VERSION).tar.bz2
IPTABLES_SITE:=http://netfilter.org/projects/iptables/files
IPTABLES_MAKE_DIR:=$(MAKE_DIR)/iptables
IPTABLES_DIR:=$(SOURCE_DIR)/iptables-$(IPTABLES_VERSION)
IPTABLES_BINARY:=$(IPTABLES_DIR)/iptables
IPTABLES_TARGET_DIR:=kernel/root/usr/sbin
IPTABLES_TARGET_BINARY:=$(IPTABLES_TARGET_DIR)/iptables
IPTABLES_EXTENSIONS_DIR:=kernel/root/usr/lib/iptables
IPTABLES_KERNEL_DIR:=$(SOURCE_DIR)/ref-$(KERNEL_REF)-$(AVM_VERSION)/kernel

$(DL_DIR)/$(IPTABLES_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(IPTABLES_SITE)/$(IPTABLES_SOURCE)

$(IPTABLES_DIR)/.unpacked $(IPTABLES_DIR_SYMLINK)/.unpacked: $(DL_DIR)/$(IPTABLES_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(IPTABLES_SOURCE)
	for i in $(IPTABLES_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(IPTABLES_DIR) $$i; \
	done
	chmod +x $(IPTABLES_DIR)/extensions/.*-test*
	touch $@

$(IPTABLES_BINARY): \
		$(IPTABLES_DIR)/.unpacked | $(IPTABLES_KERNEL_DIR)/.unpacked
	$(MAKE) KERNEL_DIR="$(shell pwd)/$(IPTABLES_KERNEL_DIR)/linux" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		COPT_FLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-rdynamic" \
		PREFIX=/usr \
		DO_IPV6=0 \
		-C $(IPTABLES_DIR)

$(IPTABLES_TARGET_BINARY): $(IPTABLES_BINARY)
	mkdir -p $(IPTABLES_TARGET_DIR)
	$(INSTALL_BINARY_STRIP)
	mkdir -p $(IPTABLES_EXTENSIONS_DIR)
	cp $(IPTABLES_DIR)/extensions/*.so $(IPTABLES_EXTENSIONS_DIR)/
	$(TARGET_STRIP) $(IPTABLES_EXTENSIONS_DIR)/*.so

iptables-precompiled: uclibc $(IPTABLES_TARGET_BINARY)

iptables-source: $(IPTABLES_DIR)/.unpacked

iptables-clean:
	-$(MAKE) -C $(IPTABLES_DIR) clean

iptables-uninstall:
	rm -f $(IPTABLES_TARGET_BINARY)
	rm -f $(IPTABLES_EXTENSIONS_DIR)/*

iptables-dirclean:
	rm -rf $(IPTABLES_DIR)
