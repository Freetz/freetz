PHP_VERSION:=5.2.1
PHP_SOURCE:=php-$(PHP_VERSION).tar.bz2
# A really strange URL
PHP_SITE:=http://www.php.net/get/$(PHP_SOURCE)/from/de.php.net/mirror
PHP_DIR:=$(SOURCE_DIR)/php-$(PHP_VERSION)
PHP_MAKE_DIR:=$(MAKE_DIR)/php
PHP_TARGET_BINARY:=php
# Use Apache package directory for PHP
PHP_TARGET_DIR:=$(APACHE_TARGET_DIR)/cgi-bin
PHP_PKG_VERSION:=$(APACHE_PKG_VERSION)
PHP_PKG_SOURCE:=$(APACHE_PKG_SOURCE)
PHP_PKG_SITE:=$(APACHE_PKG_SITE)

$(DL_DIR)/$(PHP_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(PHP_SITE)

#$(DL_DIR)/$(PHP_PKG_SOURCE):
#	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(PHP_PKG_SOURCE) $(PHP_PKG_SITE)

$(PHP_DIR)/.unpacked: $(DL_DIR)/$(PHP_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(PHP_SOURCE)
	for i in $(PHP_MAKE_DIR)/patches/*.all.patch; do \
		patch -d $(PHP_DIR) -p0 < $$i; \
	done
ifeq ($(strip $(DS_PHP_STATIC)),y)
	for i in $(PHP_MAKE_DIR)/patches/*.static.patch; do \
		patch -d $(PHP_DIR) -p0 < $$i; \
	done
endif
	touch $@

$(PHP_DIR)/.configured: $(PHP_DIR)/.unpacked
	( cd $(PHP_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
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
		--disable-libxml \
		--disable-dom \
		--without-iconv \
		--disable-simplexml \
		--disable-xml \
		--disable-xmlreader \
		--disable-xmlwriter \
		--without-pear \
		--without-pdo-sqlite \
		--without-sqlite \
		--disable-ipv6 \
		--enable-force-cgi-redirect \
		--enable-discard-path \
		--enable-fastcgi \
		--enable-exif \
		--with-config-file-path=php.ini \
	);
	touch $@

$(PHP_DIR)/sapi/cgi/$(PHP_TARGET_BINARY): $(PHP_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(PHP_DIR)

$(PACKAGES_DIR)/.php-$(PHP_VERSION): $(DL_DIR)/$(PHP_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(PHP_PKG_SOURCE)
	@touch $@

php: $(PACKAGES_DIR)/.php-$(PHP_VERSION)

php-package: $(PACKAGES_DIR)/.php-$(PHP_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(PHP_PKG_SOURCE) apache-$(APACHE_VERSION)

php-precompiled: uclibc $(PHP_DIR)/sapi/cgi/$(PHP_TARGET_BINARY) php
	$(TARGET_STRIP) $(PHP_DIR)/sapi/cgi/$(PHP_TARGET_BINARY)
	cp $(PHP_DIR)/sapi/cgi/$(PHP_TARGET_BINARY) $(PHP_TARGET_DIR)/$(PHP_TARGET_BINARY)

php-source: $(PHP_DIR)/.unpacked $(PACKAGES_DIR)/.php-$(PHP_VERSION)

php-clean:
	-$(MAKE) -C $(PHP_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(PHP_PKG_SOURCE)

php-dirclean:
	rm -rf $(PHP_DIR)
	rm -f $(PACKAGES_BUILD_DIR)/$(PHP_PKG_SOURCE)
	rm -rf $(PACKAGES_DIR)/apache-$(APACHE_VERSION)
	rm -f $(PACKAGES_DIR)/.apache-$(APACHE_VERSION)
	rm -f $(PACKAGES_DIR)/.php-$(PHP_VERSION)

php-uninstall:
	rm -f $(PHP_TARGET_DIR)/$(PHP_TARGET_BINARY)

php-list:
#ifeq ($(strip $(DS_PACKAGE_PHP)),y)
#	@echo "S99php-$(PHP_VERSION)" >> .static
#else
#	@echo "S99php-$(PHP_VERSION)" >> .dynamic
#endif
