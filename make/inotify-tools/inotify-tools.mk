INOTIFY_TOOLS_VERSION:=3.8
INOTIFY_TOOLS_LIB_VERSION:=0.3.1
INOTIFY_TOOLS_SOURCE:=inotify-tools-$(INOTIFY_TOOLS_VERSION).tar.gz
INOTIFY_TOOLS_SITE:=http://mesh.dl.sourceforge.net/sourceforge/inotify-tools
INOTIFY_TOOLS_DIR:=$(SOURCE_DIR)/inotify-tools-$(INOTIFY_TOOLS_VERSION)
INOTIFY_TOOLS_MAKE_DIR:=$(MAKE_DIR)/inotify-tools
INOTIFY_TOOLS_TARGET_DIR:=$(PACKAGES_DIR)/inotify-tools-$(INOTIFY_TOOLS_VERSION)/root/usr
INOTIFY_TOOLS_PKG_VERSION:=0.1
INOTIFY_TOOLS_PKG_SOURCE:=inotify-tools-$(INOTIFY_TOOLS_VERSION)-dsmod-$(INOTIFY_TOOLS_PKG_VERSION).tar.bz2
INOTIFY_TOOLS_PKG_SITE:=http://dsmod.magenbrot.net

$(DL_DIR)/$(INOTIFY_TOOLS_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(INOTIFY_TOOLS_SITE)/$(INOTIFY_TOOLS_SOURCE)

$(DL_DIR)/$(INOTIFY_TOOLS_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(INOTIFY_TOOLS_PKG_SOURCE) $(INOTIFY_TOOLS_PKG_SITE)

$(INOTIFY_TOOLS_DIR)/.unpacked: $(DL_DIR)/$(INOTIFY_TOOLS_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xvf $(DL_DIR)/$(INOTIFY_TOOLS_SOURCE)
	for i in $(INOTIFY_TOOLS_MAKE_DIR)/patches/*.patch; do \
		patch -d $(INOTIFY_TOOLS_DIR) -p0 < $$i; \
	done
	touch $@

$(INOTIFY_TOOLS_DIR)/.configured: $(INOTIFY_TOOLS_DIR)/.unpacked
	( cd $(INOTIFY_TOOLS_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
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

$(INOTIFY_TOOLS_DIR)/.compiled: $(INOTIFY_TOOLS_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(INOTIFY_TOOLS_DIR)
	touch $@

$(PACKAGES_DIR)/.inotify-tools-$(INOTIFY_TOOLS_VERSION): $(DL_DIR)/$(INOTIFY_TOOLS_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(INOTIFY_TOOLS_PKG_SOURCE)
	@touch $@

inotify-tools: $(PACKAGES_DIR)/.inotify-tools-$(INOTIFY_TOOLS_VERSION)

inotify-tools-package: $(PACKAGES_DIR)/.inotify-tools-$(INOTIFY_TOOLS_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(INOTIFY_TOOLS_PKG_SOURCE) inotify-tools-$(INOTIFY_TOOLS_VERSION)

inotify-tools-precompiled: uclibc $(INOTIFY_TOOLS_DIR)/.compiled inotify-tools
	$(TARGET_STRIP) $(INOTIFY_TOOLS_DIR)/src/.libs/inotifywait
	$(TARGET_STRIP) $(INOTIFY_TOOLS_DIR)/src/.libs/inotifywatch
	$(TARGET_STRIP) $(INOTIFY_TOOLS_DIR)/libinotifytools/src/.libs/libinotifytools.so.$(INOTIFY_TOOLS_LIB_VERSION)
	cp $(INOTIFY_TOOLS_DIR)/src/.libs/inotifywait $(INOTIFY_TOOLS_TARGET_DIR)/bin
	cp $(INOTIFY_TOOLS_DIR)/src/.libs/inotifywatch $(INOTIFY_TOOLS_TARGET_DIR)/bin
	cp -d $(INOTIFY_TOOLS_DIR)/libinotifytools/src/.libs/libinotifytools.so* $(INOTIFY_TOOLS_TARGET_DIR)/lib

inotify-tools-source: $(INOTIFY_TOOLS_DIR)/.unpacked $(PACKAGES_DIR)/.inotify-tools-$(INOTIFY_TOOLS_VERSION)

inotify-tools-uninstall:
	rm -f $(INOTIFY_TOOLS_TARGET_DIR)/bin/inotifywait
	rm -f $(INOTIFY_TOOLS_TARGET_DIR)/bin/inotifywatch
	rm -f $(INOTIFY_TOOLS_TARGET_DIR)/lib/libinotifytools.so*

inotify-tools-clean:
	-$(MAKE) -C $(INOTIFY_TOOLS_DIR) clean
	rm -f $(INOTIFY_TOOLS_DIR)/.compiled
	rm -f $(PACKAGES_BUILD_DIR)/$(INOTIFY_TOOLS_PKG_SOURCE)

inotify-tools-dirclean:
	rm -rf $(INOTIFY_TOOLS_DIR)
	rm -rf $(PACKAGES_DIR)/inotify-tools-$(INOTIFY_TOOLS_VERSION)
	rm -f $(PACKAGES_DIR)/.inotify-tools-$(INOTIFY_TOOLS_VERSION)

inotify-tools-list:
ifeq ($(strip $(DS_PACKAGE_INOTIFY_TOOLS)),y)
	@echo "S40inotify-tools-$(INOTIFY_TOOLS_VERSION)" >> .static
else
	@echo "S40inotify-tools-$(INOTIFY_TOOLS_VERSION)" >> .dynamic
endif
