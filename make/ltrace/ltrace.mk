LTRACE_SVN_REVISION:=77
LTRACE_VERSION:=0.5_$(LTRACE_SVN_REVISION)
LTRACE_SOURCE:=ltrace-$(LTRACE_VERSION).tar.bz2
LTRACE_SITE:=http://dsmod.magenbrot.net
LTRACE_MAKE_DIR:=$(MAKE_DIR)/ltrace
LTRACE_DIR:=$(SOURCE_DIR)/ltrace-$(LTRACE_VERSION)
LTRACE_BINARY:=$(LTRACE_DIR)/ltrace
LTRACE_CONF:=$(LTRACE_DIR)/etc/ltrace.conf
LTRACE_TARGET_DIR:=$(PACKAGES_DIR)/ltrace-$(LTRACE_VERSION)
LTRACE_TARGET_BINARY:=$(LTRACE_TARGET_DIR)/root/usr/sbin/ltrace
LTRACE_TARGET_CONF:=$(LTRACE_TARGET_DIR)/root/etc/ltrace.conf
LTRACE_PKG_VERSION:=0.1
LTRACE_PKG_SOURCE:=ltrace-$(LTRACE_VERSION)-dsmod-$(LTRACE_PKG_VERSION).tar.bz2
LTRACE_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

# Remarks:
#   - LTRACE_SOURCE is created like this:
#     svn export -r 77 svn://svn.debian.org/ltrace/ltrace/trunk ltrace-0.5_77
#     tar cvjf ltrace-0.5_77.tar.bz2 ltrace-0.5_77/
#   - Because we do not want the build process to depend on the availability
#     of a Subversion client (svn checkout), we provide the ltrace source
#     package as a download on DS-Mod mirrors and use DL_TOOL to download it.

$(DL_DIR)/$(LTRACE_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(LTRACE_SOURCE) $(LTRACE_PKG_SITE)

$(DL_DIR)/$(LTRACE_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(LTRACE_PKG_SOURCE) $(LTRACE_PKG_SITE)

$(LTRACE_DIR)/.unpacked: $(DL_DIR)/$(LTRACE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(LTRACE_SOURCE)
	for i in $(LTRACE_MAKE_DIR)/patches/*.patch; do \
		patch -d $(LTRACE_DIR) -p0 < $$i; \
	done
	touch $@

$(LTRACE_DIR)/configure: $(LTRACE_DIR)/.unpacked
	( cd $(LTRACE_DIR); ./autogen.sh )

$(LTRACE_DIR)/.configured: $(LTRACE_DIR)/configure
	#$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf.so
	( cd $(LTRACE_DIR)/sysdeps/linux-gnu/mipsel; \
		../mksyscallent $(TARGET_MAKE_PATH)/../include/asm/unistd.h > syscallent.h; \
		../mksignalent $(TARGET_MAKE_PATH)/../include/asm/signal.h > signalent.h; \
	)
	( cd $(LTRACE_DIR); \
		rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
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

$(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION): $(DL_DIR)/$(LTRACE_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(LTRACE_PKG_SOURCE)
	@touch $@

$(LTRACE_CONF): $(LTRACE_DIR)/.unpacked
	touch $@

$(LTRACE_TARGET_CONF): $(LTRACE_CONF)
	cp $(LTRACE_CONF) $(LTRACE_TARGET_CONF)

$(LTRACE_BINARY): $(LTRACE_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(LTRACE_DIR) ARCH=mipsel

$(LTRACE_TARGET_BINARY): $(LTRACE_BINARY)
	$(TARGET_STRIP) $(LTRACE_BINARY)
	cp $(LTRACE_BINARY) $(LTRACE_TARGET_BINARY)

ltrace: $(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION)

ltrace-package: $(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(LTRACE_PKG_SOURCE) ltrace-$(LTRACE_VERSION)

ltrace-precompiled: uclibc libelf-precompiled ltrace $(LTRACE_TARGET_BINARY) $(LTRACE_TARGET_CONF)

ltrace-source: $(LTRACE_DIR)/.unpacked $(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION)

ltrace-clean:
	-$(MAKE) -C $(LTRACE_DIR) clean ARCH=mipsel
	rm -f $(PACKAGES_BUILD_DIR)/$(LTRACE_PKG_SOURCE)

ltrace-dirclean:
	rm -rf $(LTRACE_DIR)
	rm -rf $(PACKAGES_DIR)/ltrace-$(LTRACE_VERSION)
	rm -f $(PACKAGES_DIR)/.ltrace-$(LTRACE_VERSION)

ltrace-uninstall:
	rm -f $(LTRACE_TARGET_BINARY)
	rm -f $(LTRACE_TARGET_CONF)

ltrace-list:
ifeq ($(strip $(DS_PACKAGE_LTRACE)),y)
	@echo "S40ltrace-$(LTRACE_VERSION)" >> .static
else
	@echo "S40ltrace-$(LTRACE_VERSION)" >> .dynamic
endif
