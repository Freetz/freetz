BIRD_VERSION:=1.0.11
BIRD_SOURCE:=bird-$(BIRD_VERSION).tar.gz
BIRD_SITE:=ftp://bird.network.cz/pub/bird
BIRD_MAKE_DIR:=$(MAKE_DIR)/bird
BIRD_DIR:=$(SOURCE_DIR)/bird-$(BIRD_VERSION)
BIRD_BINARY:=$(BIRD_DIR)/bird
BIRD_TARGET_DIR:=$(PACKAGES_DIR)/bird-$(BIRD_VERSION)
BIRD_TARGET_BINARY:=$(BIRD_TARGET_DIR)/root/usr/sbin/bird
BIRD_PKG_VERSION:=0.2
BIRD_PKG_SITE:=http://www.heimpold.de/dsmod
BIRD_PKG_NAME:=bird-$(BIRD_VERSION)
BIRD_PKG_SOURCE:=bird-$(BIRD_VERSION)-dsmod-$(BIRD_PKG_VERSION).tar.bz2

ifeq ($(strip $(DS_PACKAGE_BIRDC)),y)
BIRD_CLIENT:=--enable-client
BIRD_CLIENT_BINARY:=$(BIRD_DIR)/birdc
BIRD_CLIENT_TARGET_BINARY:=$(BIRD_TARGET_DIR)/root/usr/sbin/birdc
else
BIRD_CLIENT:=--disable-client
endif

ifeq ($(strip $(DS_PACKAGE_BIRD_DEBUG)),y)
BIRD_DEBUG:=--enable-debug
else
BIRD_DEBUG:=--disable-debug
endif

BIRD_CONFIGURE_OPTIONS=$(BIRD_DEBUG) --disable-memcheck --disable-warnings $(BIRD_CLIENT) --disable-ipv6

$(DL_DIR)/$(BIRD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(BIRD_SITE)/$(BIRD_SOURCE)

$(DL_DIR)/$(BIRD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(BIRD_PKG_SOURCE) $(BIRD_PKG_SITE)

$(BIRD_DIR)/.unpacked: $(DL_DIR)/$(BIRD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(BIRD_SOURCE)
	for i in $(BIRD_MAKE_DIR)/patches/*.patch; do \
		patch -d $(BIRD_DIR) -p1 < $$i; \
	done
	touch $@

$(BIRD_DIR)/.configured: $(BIRD_DIR)/.unpacked
	( cd $(BIRD_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -D_XOPEN_SOURCE=600" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include -D_XOPEN_SOURCE=600" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
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
		$(BIRD_CONFIGURE_OPTIONS) \
	);
	touch $@

$(BIRD_BINARY) $(BIRD_CLIENT_BINARY): $(BIRD_DIR)/.configured
	PATH="$(TARGET_PATH)" LD="$(TARGET_LD)" $(MAKE1) -C $(BIRD_DIR)
	touch $@

$(PACKAGES_DIR)/.$(BIRD_PKG_NAME): $(DL_DIR)/$(BIRD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(BIRD_PKG_SOURCE)
	@touch $@

$(BIRD_TARGET_BINARY): $(BIRD_BINARY)
	$(TARGET_STRIP) $(BIRD_BINARY)
	cp $(BIRD_BINARY) $(BIRD_TARGET_BINARY)

ifeq ($(strip $(DS_PACKAGE_BIRDC)),y)
$(BIRD_CLIENT_TARGET_BINARY): $(BIRD_CLIENT_BINARY)
	$(TARGET_STRIP) $(BIRD_CLIENT_BINARY)
	cp $(BIRD_CLIENT_BINARY) $(BIRD_CLIENT_TARGET_BINARY)
endif

bird: $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)

bird-package: $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(BIRD_PKG_SOURCE) $(BIRD_PKG_NAME)

bird-precompiled: uclibc ncurses-precompiled readline-precompiled bird $(BIRD_TARGET_BINARY) $(BIRD_CLIENT_TARGET_BINARY)

bird-source: $(BIRD_DIR)/.unpacked $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)

bird-clean:
	-$(MAKE) -C $(BIRD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(BIRD_PKG_SOURCE)

bird-dirclean:
	rm -rf $(BIRD_DIR)
	rm -rf $(PACKAGES_DIR)/$(BIRD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)

bird-uninstall:
	rm -f $(BIRD_TARGET_BINARY)
	rm -f $(BIRD_CLIENT_TARGET_BINARY)

bird-list:
ifeq ($(strip $(DS_PACKAGE_BIRD)),y)
	@echo "S80bird-$(BIRD_VERSION)" >> .static
else
	@echo "S80bird-$(BIRD_VERSION)" >> .dynamic
endif
