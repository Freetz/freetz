LYNX_VERSION:=2.8.5
LYNX_SOURCE:=lynx$(LYNX_VERSION).tar.bz2
LYNX_SITE:=http://lynx.isc.org/lynx$(LYNX_VERSION)
LYNX_DIR:=$(SOURCE_DIR)/lynx2-8-5
LYNX_MAKE_DIR:=$(MAKE_DIR)/lynx
LYNX_PKG_VERSION:=0.1
LYNX_PKG_SITE:=http://www.heimpold.de/dsmod
LYNX_PKG_NAME:=lynx-$(LYNX_VERSION)
LYNX_PKG_SOURCE:=lynx-$(LYNX_VERSION)-dsmod-$(LYNX_PKG_VERSION).tar.bz2
LYNX_TARGET_DIR:=$(PACKAGES_DIR)/$(LYNX_PKG_NAME)/root/usr/bin
LYNX_TARGET_BINARY:=lynx
LYNX_TARGET_CFGDIR:=$(PACKAGES_DIR)/$(LYNX_PKG_NAME)/root/etc
LYNX_TARGET_CFG:=lynx.cfg

LYNX_CONFIGURE_OPTIONS=\
  --enable-warnings \
  --with-screen=ncurses \
  --enable-nested-tables --enable-read-eta \
  --enable-charset-choice \
  --disable-alt-bindings \
  --disable-bibp-urls \
  --disable-config-info \
  --disable-dired \
  --disable-finger \
  --disable-gopher \
  --disable-news \
  --disable-nls \
  --disable-prettysrc \
  --disable-source-cache \
  --disable-trace \

$(DL_DIR)/$(LYNX_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LYNX_SITE)/$(LYNX_SOURCE)

$(DL_DIR)/$(LYNX_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(LYNX_PKG_SOURCE) $(LYNX_PKG_SITE)

$(LYNX_DIR)/.unpacked: $(DL_DIR)/$(LYNX_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(LYNX_SOURCE)
	for i in $(LYNX_MAKE_DIR)/patches/*.patch; do \
		patch -d $(LYNX_DIR) -p1 < $$i; \
	done
	touch $@

$(LYNX_DIR)/.configured: $(LYNX_DIR)/.unpacked
	( cd $(LYNX_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
		ac_cv_prog_CC="$(GNU_TARGET_NAME)-gcc" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--datadir=/usr/share \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--libdir=/etc \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--mandir=/usr/share/man \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		$(LYNX_CONFIGURE_OPTIONS) \
	);
	touch $@

$(LYNX_DIR)/$(LYNX_TARGET_BINARY): $(LYNX_DIR)/.configured
	PATH="$(TARGET_PATH)" LD="$(TARGET_LD)" $(MAKE) -C $(LYNX_DIR)
	touch $@

$(PACKAGES_DIR)/.$(LYNX_PKG_NAME): $(DL_DIR)/$(LYNX_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(LYNX_PKG_SOURCE)
	@touch $@

lynx: $(PACKAGES_DIR)/.$(LYNX_PKG_NAME)

lynx-package: $(PACKAGES_DIR)/.$(LYNX_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(LYNX_PKG_SOURCE) $(LYNX_PKG_NAME)

lynx-precompiled: uclibc ncurses-precompiled $(LYNX_DIR)/$(LYNX_TARGET_BINARY) lynx
	$(TARGET_STRIP) $(LYNX_DIR)/$(LYNX_TARGET_BINARY)
	mkdir -p $(LYNX_TARGET_DIR)
	cp $(LYNX_DIR)/$(LYNX_TARGET_BINARY) $(LYNX_TARGET_DIR)
	cp $(LYNX_DIR)/$(LYNX_TARGET_CFG) $(LYNX_TARGET_CFGDIR)

lynx-source: $(LYNX_DIR)/.unpacked $(PACKAGES_DIR)/.$(LYNX_PKG_NAME)

lynx-clean:
	-$(MAKE) -C $(LYNX_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(LYNX_PKG_SOURCE)

lynx-dirclean:
	rm -rf $(LYNX_DIR)
	rm -rf $(PACKAGES_DIR)/$(LYNX_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(LYNX_PKG_NAME)

lynx-list:
ifeq ($(strip $(DS_PACKAGE_LYNX)),y)
	@echo "S99lynx-$(LYNX_VERSION)" >> .static
else
	@echo "S99lynx-$(LYNX_VERSION)" >> .dynamic
endif
