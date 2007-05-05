STRACE_VERSION:=4.5.12
# This one did not compile without problems
# STRACE_VERSION:=4.5.15
STRACE_SOURCE:=strace-$(STRACE_VERSION).tar.bz2
STRACE_SITE:=http://mesh.dl.sourceforge.net/sourceforge/strace
STRACE_DIR:=$(SOURCE_DIR)/strace-$(STRACE_VERSION)
STRACE_MAKE_DIR:=$(MAKE_DIR)/strace
STRACE_TARGET_DIR:=$(PACKAGES_DIR)/strace-$(STRACE_VERSION)/root/usr/sbin
STRACE_TARGET_BINARY:=strace
STRACE_PKG_SOURCE:=strace-$(STRACE_VERSION)-dsmod.tar.bz2
STRACE_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

$(DL_DIR)/$(STRACE_SOURCE):
	wget -P $(DL_DIR) $(STRACE_SITE)/$(STRACE_SOURCE)

$(DL_DIR)/$(STRACE_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(STRACE_PKG_SOURCE) $(STRACE_PKG_SITE)

$(STRACE_DIR)/.unpacked: $(DL_DIR)/$(STRACE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(STRACE_SOURCE)
#	for i in $(STRACE_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(STRACE_DIR) -p0 < $$i; \
#	done
	touch $@

$(STRACE_DIR)/.configured: $(STRACE_DIR)/.unpacked
	( cd $(STRACE_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-static-libgcc" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
	);
	touch $@

$(STRACE_DIR)/$(STRACE_TARGET_BINARY): $(STRACE_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(STRACE_DIR)

$(PACKAGES_DIR)/.strace-$(STRACE_VERSION): $(DL_DIR)/$(STRACE_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(STRACE_PKG_SOURCE)
	@touch $@

strace: $(PACKAGES_DIR)/.strace-$(STRACE_VERSION)

strace-package: $(PACKAGES_DIR)/.strace-$(STRACE_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(STRACE_PKG_SOURCE) strace-$(STRACE_VERSION)

strace-precompiled: uclibc $(STRACE_DIR)/$(STRACE_TARGET_BINARY) strace
	$(TARGET_STRIP) $(STRACE_DIR)/$(STRACE_TARGET_BINARY)
	cp $(STRACE_DIR)/$(STRACE_TARGET_BINARY) $(STRACE_TARGET_DIR)/

strace-source: $(STRACE_DIR)/.unpacked $(PACKAGES_DIR)/.strace-$(STRACE_VERSION)

strace-clean:
	-$(MAKE) -C $(STRACE_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(STRACE_PKG_SOURCE)

strace-dirclean:
	rm -rf $(STRACE_DIR)
	rm -rf $(PACKAGES_DIR)/strace-$(STRACE_VERSION)
	rm -f $(PACKAGES_DIR)/.strace-$(STRACE_VERSION)

strace-list:
ifeq ($(strip $(DS_PACKAGE_STRACE)),y)
	@echo "S40strace-$(STRACE_VERSION)" >> .static
else
	@echo "S40strace-$(STRACE_VERSION)" >> .dynamic
endif
