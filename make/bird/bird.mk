BIRD_VERSION:=1.0.11
BIRD_SOURCE:=bird-$(BIRD_VERSION).tar.gz
BIRD_SITE:=ftp://bird.network.cz/pub/bird
BIRD_DIR:=$(SOURCE_DIR)/bird-$(BIRD_VERSION)
BIRD_MAKE_DIR:=$(MAKE_DIR)/bird
BIRD_PKG_VERSION:=0.1
BIRD_PKG_SITE:=http://www.heimpold.de/dsmod
BIRD_PKG_NAME:=bird-$(BIRD_VERSION)
BIRD_PKG_SOURCE:=bird-$(BIRD_VERSION)-dsmod-$(BIRD_PKG_VERSION).tar.bz2
BIRD_TARGET_DIR:=$(PACKAGES_DIR)/$(BIRD_PKG_NAME)/root/usr/sbin
ifeq ($(strip $(DS_PACKAGE_BIRDC)),y)
BIRD_TARGET_BIRD_BINARY:=bird
BIRD_TARGET_BIRDC_BINARY:=birdc
BIRD_CLIENT:=--enable-client
else
BIRD_TARGET_BIRD_BINARY:=bird
BIRD_CLIENT:=--disable-client
endif

$(DL_DIR)/$(BIRD_SOURCE):
	wget -P $(DL_DIR) $(BIRD_SITE)/$(BIRD_SOURCE)

$(DL_DIR)/$(BIRD_PKG_SOURCE):
	@wget -P $(DL_DIR) $(BIRD_PKG_SITE)/$(BIRD_PKG_SOURCE)

$(BIRD_DIR)/.unpacked: $(DL_DIR)/$(BIRD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(BIRD_SOURCE)
	for i in $(BIRD_MAKE_DIR)/patches/*.patch; do \
	    patch -d $(BIRD_DIR) -p1 < $$i; \
	done
	touch $@

$(BIRD_DIR)/.configured: readline $(BIRD_DIR)/.unpacked
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
		--disable-debug \
  		--disable-memcheck \
		--disable-warnings \
		$(BIRD_CLIENT) \
		--disable-ipv6 \
	);
	touch $@

$(BIRD_DIR)/.built: $(BIRD_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		LD="$(TARGET_LD)" \
		$(MAKE) -C $(BIRD_DIR)
	touch $@

$(BIRD_DIR)/.installed: $(BIRD_DIR)/.built
	touch $@

$(PACKAGES_DIR)/.$(BIRD_PKG_NAME): $(DL_DIR)/$(BIRD_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(BIRD_PKG_SOURCE)
	@touch $@

bird: $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)

bird-package: $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(BIRD_PKG_SOURCE) $(BIRD_PKG_NAME)

bird-precompiled: $(BIRD_DIR)/.installed bird
	$(TARGET_STRIP) $(BIRD_DIR)/$(BIRD_TARGET_BIRD_BINARY)
ifeq ($(strip $(DS_PACKAGE_BIRDC)),y)
		$(TARGET_STRIP) $(BIRD_DIR)/$(BIRD_TARGET_BIRDC_BINARY)
endif
	mkdir -p $(BIRD_TARGET_DIR)
	cp $(BIRD_DIR)/$(BIRD_TARGET_BIRD_BINARY) $(BIRD_TARGET_DIR)
ifeq ($(strip $(DS_PACKAGE_BIRDC)),y)
		cp $(BIRD_DIR)/$(BIRD_TARGET_BIRDC_BINARY) $(BIRD_TARGET_DIR)
endif

bird-source: $(BIRD_DIR)/.unpacked $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)

bird-clean:
	-$(MAKE) -C $(BIRD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(BIRD_PKG_SOURCE)

bird-dirclean:
	rm -rf $(BIRD_DIR)
	rm -rf $(PACKAGES_DIR)/$(BIRD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(BIRD_PKG_NAME)

bird-list:
ifeq ($(strip $(DS_PACKAGE_BIRD)),y)
	@echo "S60bird-$(BIRD_VERSION)" >> .static
else
	@echo "S60bird-$(BIRD_VERSION)" >> .dynamic
endif
