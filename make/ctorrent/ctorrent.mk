PACKAGE_LC:=ctorrent
PACKAGE_UC:=CTORRENT
CTORRENT_VERSION:=dnh3.2
CTORRENT_SOURCE:=ctorrent-$(CTORRENT_VERSION).tar.gz
CTORRENT_SITE:=http://www.rahul.net/dholmes/ctorrent/
CTORRENT_MAKE_DIR:=$(MAKE_DIR)/ctorrent
CTORRENT_DIR:=$(SOURCE_DIR)/ctorrent-$(CTORRENT_VERSION)
CTORRENT_BINARY:=$(CTORRENT_DIR)/ctorrent
CTORRENT_TARGET_DIR:=$(PACKAGES_DIR)/ctorrent-$(CTORRENT_VERSION)
CTORRENT_TARGET_BINARY:=$(CTORRENT_TARGET_DIR)/root/usr/bin/ctorrent
CTORRENT_PKG_VERSION:=0.1
CTORRENT_STARTLEVEL=40

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)

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

$(CTORRENT_BINARY): $(CTORRENT_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CTORRENT_DIR) all

$(CTORRENT_TARGET_BINARY): $(CTORRENT_BINARY)
	mkdir -p $(dir $(CTORRENT_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

ctorrent: 

ctorrent-precompiled: uclibc uclibcxx-precompiled ctorrent $(CTORRENT_TARGET_BINARY)

ctorrent-source: $(CTORRENT_DIR)/.unpacked

ctorrent-clean:
	-$(MAKE) -C $(CTORRENT_DIR) clean

ctorrent-dirclean:
	rm -rf $(CTORRENT_DIR)
	rm -rf $(PACKAGES_DIR)/ctorrent-$(CTORRENT_VERSION)
	rm -f $(PACKAGES_DIR)/.ctorrent-$(CTORRENT_VERSION)

ctorrent-uninstall:
	rm -f $(CTORRENT_TARGET_BINARY)

$(PACKAGE_LIST)
