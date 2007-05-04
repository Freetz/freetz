CTORRENT_VERSION:=1.3.4-dnh3
CTORRENT_SOURCE:=ctorrent-$(CTORRENT_VERSION).tar.gz
CTORRENT_SITE:=http://www.rahul.net/dholmes/ctorrent/
CTORRENT_DIR:=$(SOURCE_DIR)/ctorrent-dnh3
CTORRENT_MAKE_DIR:=$(MAKE_DIR)/ctorrent
CTORRENT_TARGET_DIR:=$(PACKAGES_DIR)/ctorrent-$(CTORRENT_VERSION)/root/usr/bin
CTORRENT_TARGET_BINARY:=ctorrent
CTORRENT_PKG_VERSION:=0.1
CTORRENT_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
CTORRENT_PKG_SOURCE:=ctorrent-$(CTORRENT_VERSION)-dsmod-binary-only.tar.bz2

$(DL_DIR)/$(CTORRENT_SOURCE):
	wget -P $(DL_DIR) $(CTORRENT_SITE)/$(CTORRENT_SOURCE)

$(DL_DIR)/$(CTORRENT_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(CTORRENT_PKG_SOURCE) $(CTORRENT_PKG_SITE)

$(CTORRENT_DIR)/.unpacked: $(DL_DIR)/$(CTORRENT_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(CTORRENT_SOURCE)
#	for i in $(CTORRENT_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(CTORRENT_DIR) -p1 < $$i; \
#	done
	touch $@

$(CTORRENT_DIR)/.configured: $(CTORRENT_DIR)/.unpacked 
	( cd $(CTORRENT_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include " \
		CXXFLAGS="-Os" \
		LIBS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		CXX="mipsel-linux-g++-uc" \
		./configure \
		--target="$(GNU_TARGET_NAME)" \
		--host="$(GNU_TARGET_NAME)" \
		--build="$(GNU_HOST_NAME)" \
		--prefix=/usr \
		--with-ssl=no \
	);
	touch $@

$(CTORRENT_DIR)/$(CTORRENT_TARGET_BINARY): $(CTORRENT_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CTORRENT_DIR) all

$(PACKAGES_DIR)/.ctorrent-$(CTORRENT_VERSION): $(DL_DIR)/$(CTORRENT_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CTORRENT_PKG_SOURCE)
	@touch $@

ctorrent: $(PACKAGES_DIR)/.ctorrent-$(CTORRENT_VERSION)

ctorrent-package: $(PACKAGES_DIR)/.ctorrent-$(CTORRENT_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(CTORRENT_PKG_SOURCE) ctorrent-$(CTORRENT_VERSION)

ctorrent-precompiled: $(CTORRENT_DIR)/$(CTORRENT_TARGET_BINARY) ctorrent
	$(TARGET_STRIP) $(CTORRENT_DIR)/$(CTORRENT_TARGET_BINARY)
	cp $(CTORRENT_DIR)/$(CTORRENT_TARGET_BINARY) $(CTORRENT_TARGET_DIR)/

ctorrent-source: $(CTORRENT_DIR)/.unpacked $(PACKAGES_DIR)/.ctorrent-$(CTORRENT_VERSION)

ctorrent-clean:
	-$(MAKE) -C $(CTORRENT_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(CTORRENT_PKG_SOURCE)

ctorrent-dirclean:
	rm -rf $(CTORRENT_DIR)
	rm -rf $(PACKAGES_DIR)/ctorrent-$(CTORRENT_VERSION)
	rm -f $(PACKAGES_DIR)/.ctorrent-$(CTORRENT_VERSION)

ctorrent-list:
ifeq ($(strip $(DS_PACKAGE_CTORRENT)),y)
	@echo "S40ctorrent-$(CTORRENT_VERSION)" >> .static
else
	@echo "S40ctorrent-$(CTORRENT_VERSION)" >> .dynamic
endif
