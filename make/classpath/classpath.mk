CLASSPATH_VERSION:=0.95
CLASSPATH_SOURCE:=classpath-$(CLASSPATH_VERSION).tar.gz
CLASSPATH_SITE:=ftp://ftp.gnu.org/gnu/classpath
CLASSPATH_MAKE_DIR:=$(MAKE_DIR)/classpath
CLASSPATH_DIR:=$(SOURCE_DIR)/classpath-$(CLASSPATH_VERSION)
CLASSPATH_BINARY:=$(CLASSPATH_DIR)/lib/mini.jar
CLASSPATH_TARGET_DIR:=$(PACKAGES_DIR)/classpath-$(CLASSPATH_VERSION)
CLASSPATH_TARGET_BINARY:=$(CLASSPATH_TARGET_DIR)/root/usr/share/classpath/mini.jar
CLASSPATH_PKG_VERSION:=0.1
CLASSPATH_PKG_SOURCE:=CLASSPATH-$(CLASSPATH_VERSION)-dsmod-$(CLASSPATH_PKG_VERSION).tar.bz2
CLASSPATH_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
CLASSPATH_PKG_SOURCE:=classpath-$(CLASSPATH_VERSION)-dsmod.tar.bz2

$(DL_DIR)/$(CLASSPATH_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(CLASSPATH_SITE)/$(CLASSPATH_SOURCE)

$(DL_DIR)/$(CLASSPATH_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(CLASSPATH_PKG_SOURCE) $(CLASSPATH_PKG_SITE)

$(CLASSPATH_DIR)/.unpacked: $(DL_DIR)/$(CLASSPATH_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(CLASSPATH_SOURCE)
#	for i in $(CLASSPATH_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(CLASSPATH_DIR) -p1 < $$i; \
#	done
	touch $@

$(CLASSPATH_DIR)/.configured: $(CLASSPATH_DIR)/.unpacked
	( cd $(CLASSPATH_DIR); rm -f config.status; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		./configure \
		--target="$(GNU_TARGET_NAME)" \
		--host="$(GNU_TARGET_NAME)" \
		--build="$(GNU_HOST_NAME)" \
		--prefix="/usr" \
		--disable-gtk-peer \
		--disable-qt-peer \
		--disable-gconf-peer \
		--without-libiconv-prefix \
		--disable-plugin \
		--with-ecj \
		--disable-Werror \
	);
	touch $@

$(CLASSPATH_BINARY): $(CLASSPATH_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(CLASSPATH_DIR)
	cp $(CLASSPATH_MAKE_DIR)/mini.classlist $(CLASSPATH_DIR)/lib;
	( cd $(CLASSPATH_DIR)/lib; fastjar -Mcf mini.jar -@ < mini.classlist );

$(CLASSPATH_TARGET_BINARY): $(CLASSPATH_BINARY)
	cp $(CLASSPATH_BINARY) $(CLASSPATH_TARGET_BINARY)

$(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION): $(DL_DIR)/$(CLASSPATH_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CLASSPATH_PKG_SOURCE)
	@touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so: $(CLASSPATH_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(CLASSPATH_DIR)/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	touch -c $@

$(CLASSPATH_DIR)/.installed: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so
	mkdir -p root/usr/lib/classpath
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/lib*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/lib*.so* root/usr/lib/classpath
	touch $@

classpath: $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)

classpath-package: $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(CLASSPATH_PKG_SOURCE) classpath-$(CLASSPATH_VERSION)

classpath-precompiled: uclibc $(CLASSPATH_DIR)/.installed classpath $(CLASSPATH_TARGET_BINARY)

classpath-source: $(CLASSPATH_DIR)/.unpacked $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)

classpath-clean:
	-$(MAKE) -C $(CLASSPATH_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(CLASSPATH_PKG_SOURCE)

classpath-dirclean:
	rm -rf $(CLASSPATH_DIR)
	rm -rf $(PACKAGES_DIR)/classpath-$(CLASSPATH_VERSION)
	rm -f $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)

classpath-uninstall:
	rm -f $(CLASSPATH_TARGET_BINARY)
	rm -rf root/usr/lib/classpath
	rm -f $(CLASSPATH_DIR)/.installed

classpath-list:
ifeq ($(strip $(DS_PACKAGE_CLASSPATH)),y)
	@echo "S40classpath-$(CLASSPATH_VERSION)" >> .static
else
	@echo "S40classpath-$(CLASSPATH_VERSION)" >> .dynamic
endif
