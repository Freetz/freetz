PACKAGE_LC:=cpmaccfg
PACKAGE_UC:=CPMACCFG
CPMACCFG_VERSION:=0.4
CPMACCFG_SOURCE:=cpmaccfg-$(CPMACCFG_VERSION).tar.gz
CPMACCFG_SITE:=http://www.heimpold.de/dsmod
CPMACCFG_MAKE_DIR:=$(MAKE_DIR)/cpmaccfg
CPMACCFG_DIR:=$(SOURCE_DIR)/cpmaccfg-$(CPMACCFG_VERSION)
CPMACCFG_BINARY:=$(CPMACCFG_DIR)/cpmaccfg
CPMACCFG_PKG_VERSION:=0.2a
CPMACCFG_PKG_NAME:=cpmaccfg-$(CPMACCFG_VERSION)
CPMACCFG_TARGET_DIR:=$(PACKAGES_DIR)/$(CPMACCFG_PKG_NAME)
CPMACCFG_TARGET_BINARY:=$(CPMACCFG_TARGET_DIR)/root/sbin/cpmaccfg
CPMACCFG_STARTLEVEL=40

CPMACCFG_CONFIGURE_OPTIONS=

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)

$(CPMACCFG_DIR)/.configured: $(CPMACCFG_DIR)/.unpacked
	( cd $(CPMACCFG_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
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
		--libdir=/usr/lib \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--mandir=/usr/share/man \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		$(CPMACCFG_CONFIGURE_OPTIONS) \
	);
	touch $@

$(CPMACCFG_BINARY): $(CPMACCFG_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		LD="$(TARGET_LD)" \
		$(MAKE) -C $(CPMACCFG_DIR)

$(CPMACCFG_TARGET_BINARY): $(CPMACCFG_BINARY)
	mkdir -p $(dir $(CPMACCFG_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)


cpmaccfg:

cpmaccfg-precompiled: uclibc cpmaccfg $(CPMACCFG_TARGET_BINARY)

cpmaccfg-source: $(CPMACCFG_DIR)/.unpacked

cpmaccfg-clean:
	-$(MAKE) -C $(CPMACCFG_DIR) clean
	rm -f $(CPMACCFG_DIR)/.configured

cpmaccfg-dirclean:
	rm -rf $(CPMACCFG_DIR)
	rm -rf $(PACKAGES_DIR)/$(CPMACCFG_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(CPMACCFG_PKG_NAME)

cpmaccfg-uninstall:
	rm -f $(CPMACCFG_TARGET_BINARY)

$(PACKAGE_LIST)