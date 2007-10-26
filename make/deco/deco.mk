PACKAGE_LC:=deco
PACKAGE_UC:=DECO
DECO_VERSION:=39
DECO_SOURCE:=deco$(DECO_VERSION).tgz
DECO_SITE:=http://mesh.dl.sourceforge.net/sourceforge/deco
DECO_MAKE_DIR:=$(MAKE_DIR)/deco
DECO_DIR:=$(SOURCE_DIR)/deco$(DECO_VERSION)
DECO_BINARY:=$(DECO_DIR)/deco
DECO_TARGET_DIR:=$(PACKAGES_DIR)/deco-$(DECO_VERSION)
DECO_TARGET_BINARY:=$(DECO_TARGET_DIR)/root/usr/bin/deco
DECO_PKG_VERSION:=0.1
DECO_STARTLEVEL=40

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)

$(DECO_DIR)/.configured: $(DECO_DIR)/.unpacked
	( cd $(DECO_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
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

$(DECO_BINARY): $(DECO_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(DECO_DIR)

$(DECO_TARGET_BINARY): $(DECO_BINARY)
	mkdir -p $(dir $(DECO_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.deco-$(DECO_VERSION):
	mkdir -p $(DECO_TARGET_DIR)/root
	tar -c -C $(DECO_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(DECO_TARGET_DIR)
	@touch $@

deco: $(PACKAGES_DIR)/.deco-$(DECO_VERSION)

deco-precompiled: uclibc ncurses-precompiled deco $(DECO_TARGET_BINARY)

deco-source: $(DECO_DIR)/.unpacked $(PACKAGES_DIR)/.deco-$(DECO_VERSION)

deco-clean:
	-$(MAKE) -C $(DECO_DIR) clean

deco-dirclean:
	rm -rf $(DECO_DIR)
	rm -rf $(PACKAGES_DIR)/deco-$(DECO_VERSION)
	rm -f $(PACKAGES_DIR)/.deco-$(DECO_VERSION)

deco-uninstall:
	rm -f $(DECO_TARGET_BINARY)

$(PACKAGE_LIST)
