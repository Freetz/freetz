BIRD_VERSION:=1.0.11
BIRD_SOURCE:=bird-$(BIRD_VERSION).tar.gz
BIRD_SITE:=ftp://bird.network.cz/pub/bird
BIRD_MAKE_DIR:=$(MAKE_DIR)/bird
BIRD_DIR:=$(SOURCE_DIR)/bird-$(BIRD_VERSION)
BIRD_BINARY:=$(BIRD_DIR)/bird
BIRD_TARGET_DIR:=$(PACKAGES_DIR)/bird-$(BIRD_VERSION)
BIRD_TARGET_BINARY:=$(BIRD_TARGET_DIR)/root/usr/sbin/bird
BIRD_PKG_VERSION:=0.3
BIRD_PKG_SITE:=http://www.heimpold.de/dsmod
BIRD_PKG_NAME:=bird-$(BIRD_VERSION)
BIRD_PKG_SOURCE:=bird-$(BIRD_VERSION)-dsmod-$(BIRD_PKG_VERSION).tar.bz2

ifeq ($(strip $(DS_PACKAGE_BIRDC)),y)
BIRD_CLIENT_BINARY:=$(BIRD_DIR)/birdc
BIRD_CLIENT_TARGET_BINARY:=$(BIRD_TARGET_DIR)/root/usr/sbin/birdc
endif

BIRD_DS_CONFIG_FILE:=$(BIRD_MAKE_DIR)/.ds_config
BIRD_DS_CONFIG_TEMP:=$(BIRD_MAKE_DIR)/.ds_config.temp

$(DL_DIR)/$(BIRD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(BIRD_SITE)/$(BIRD_SOURCE)

$(DL_DIR)/$(BIRD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(BIRD_PKG_SOURCE) $(BIRD_PKG_SITE)

$(BIRD_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_PACKAGE_BIRD_DEBUG=$(if $(DS_PACKAGE_BIRD_DEBUG),y,n)" > $(BIRD_DS_CONFIG_TEMP)
	@echo "DS_PACKAGE_BIRDC=$(if $(DS_PACKAGE_BIRDC),y,n)" >> $(BIRD_DS_CONFIG_TEMP)
	@diff -q $(BIRD_DS_CONFIG_TEMP) $(BIRD_DS_CONFIG_FILE) || \
		cp $(BIRD_DS_CONFIG_TEMP) $(BIRD_DS_CONFIG_FILE)
	@rm -f $(BIRD_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(BIRD_DIR)/.unpacked: $(DL_DIR)/$(BIRD_SOURCE) $(BIRD_DS_CONFIG_FILE)
	rm -rf $(BIRD_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(BIRD_SOURCE)
	for i in $(BIRD_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(BIRD_DIR) $$i; \
	done
	touch $@

$(BIRD_DIR)/.configured: $(BIRD_DIR)/.unpacked
	( cd $(BIRD_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -D_XOPEN_SOURCE=600" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include -D_XOPEN_SOURCE=600" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		bird_cv_c_endian=little-endian \
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
		$(if $(DS_PACKAGE_BIRDC),--enable-client,--disable-client) \
		$(if $(DS_PACKAGE_BIRD_DEBUG),--enable-debug,--disable-debug) \
		--disable-memcheck \
		--disable-warnings \
		--disable-ipv6 \
	);
	touch $@

$(BIRD_BINARY) $(BIRD_CLIENT_BINARY): $(BIRD_DIR)/.configured
	PATH="$(TARGET_PATH)" LD="$(TARGET_LD)" $(MAKE1) -C $(BIRD_DIR)
	touch $@

$(PACKAGES_DIR)/.$(BIRD_PKG_NAME): $(DL_DIR)/$(BIRD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(BIRD_PKG_SOURCE)
	@touch $@

$(BIRD_TARGET_BINARY): $(BIRD_BINARY)
	$(INSTALL_BINARY_STRIP)

ifeq ($(strip $(DS_PACKAGE_BIRDC)),y)
$(BIRD_CLIENT_TARGET_BINARY): $(BIRD_CLIENT_BINARY)
	$(INSTALL_BINARY_STRIP)
endif

bird: $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)

bird-package: $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(BIRD_PKG_SOURCE) $(BIRD_PKG_NAME)

bird-precompiled: uclibc ncurses-precompiled readline-precompiled bird $(BIRD_TARGET_BINARY) $(BIRD_CLIENT_TARGET_BINARY)

bird-source: $(BIRD_DIR)/.unpacked $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)

bird-clean:
	-$(MAKE) -C $(BIRD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(BIRD_PKG_SOURCE)
	rm -f $(BIRD_DS_CONFIG_FILE)

bird-dirclean:
	rm -rf $(BIRD_DIR)
	rm -rf $(PACKAGES_DIR)/$(BIRD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)
	rm -f $(BIRD_DS_CONFIG_FILE)

bird-uninstall:
	rm -f $(BIRD_TARGET_BINARY)
	rm -f $(BIRD_CLIENT_TARGET_BINARY)

bird-list:
ifeq ($(strip $(DS_PACKAGE_BIRD)),y)
	@echo "S80bird-$(BIRD_VERSION)" >> .static
else
	@echo "S80bird-$(BIRD_VERSION)" >> .dynamic
endif
