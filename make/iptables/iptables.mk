IPTABLES_VERSION:=1.3.6
IPTABLES_SOURCE:=iptables-$(IPTABLES_VERSION).tar.bz2
IPTABLES_SITE:=http://netfilter.org/projects/iptables/files
IPTABLES_DIR:=$(SOURCE_DIR)/iptables-$(IPTABLES_VERSION)
IPTABLES_MAKE_DIR:=$(MAKE_DIR)/iptables
IPTABLES_TARGET_DIR:=kernel/root/usr/sbin
IPTABLES_TARGET_BINARY:=iptables
IPTABLES_EXTENSIONS_DIR:=kernel/root/usr/lib/iptables
IPTABLES_KERNEL_DIR:=$(SOURCE_DIR)/ref-$(KERNEL_REF)-$(AVM_VERSION)/kernel


$(DL_DIR)/$(IPTABLES_SOURCE):
	wget -P $(DL_DIR) $(IPTABLES_SITE)/$(IPTABLES_SOURCE)

$(IPTABLES_DIR)/.unpacked $(IPTABLES_DIR_SYMLINK)/.unpacked: $(DL_DIR)/$(IPTABLES_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(IPTABLES_SOURCE)
	for i in $(IPTABLES_MAKE_DIR)/patches/*.patch; do \
		patch -d $(IPTABLES_DIR) -p0 < $$i; \
	done
	chmod +x $(IPTABLES_DIR)/extensions/.*-test
	touch $@

$(IPTABLES_DIR)/$(IPTABLES_TARGET_BINARY): $(IPTABLES_DIR)/.unpacked \
                                           $(IPTABLES_KERNEL_DIR)/.unpacked
	$(MAKE) KERNEL_DIR="$(shell pwd)/$(IPTABLES_KERNEL_DIR)/linux" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		COPT_FLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-rdynamic -static-libgcc" \
		PREFIX=/usr \
		DO_IPV6=0 \
		-C $(IPTABLES_DIR)

iptables-precompiled: $(IPTABLES_DIR)/$(IPTABLES_TARGET_BINARY)
	$(TARGET_STRIP) $(IPTABLES_DIR)/$(IPTABLES_TARGET_BINARY)
	$(TARGET_STRIP) $(IPTABLES_DIR)/extensions/*.so
	cp $(IPTABLES_DIR)/$(IPTABLES_TARGET_BINARY) $(IPTABLES_TARGET_DIR)/
	cp $(IPTABLES_DIR)/extensions/*.so $(IPTABLES_EXTENSIONS_DIR)/

iptables-source: $(IPTABLES_DIR)/.unpacked

iptables-clean:
	-$(MAKE) -C $(IPTABLES_DIR) clean

iptables-dirclean:
	rm -rf $(IPTABLES_DIR)
