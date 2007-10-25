PACKAGE_LC:=classpath
PACKAGE_UC:=CLASSPATH
CLASSPATH_VERSION:=0.95
CLASSPATH_UGLY_VERSION:=0.0.0
CLASSPATH_SOURCE:=classpath-$(CLASSPATH_VERSION).tar.gz
CLASSPATH_SITE:=ftp://ftp.gnu.org/gnu/classpath
CLASSPATH_MAKE_DIR:=$(MAKE_DIR)/classpath
CLASSPATH_DIR:=$(SOURCE_DIR)/classpath-$(CLASSPATH_VERSION)
CLASSPATH_BINARY:=$(CLASSPATH_DIR)/lib/mini.jar
CLASSPATH_TARGET_DIR:=$(PACKAGES_DIR)/classpath-$(CLASSPATH_VERSION)
CLASSPATH_TARGET_BINARY:=$(CLASSPATH_TARGET_DIR)/root/usr/share/classpath/mini.jar
CLASSPATH_PKG_VERSION:=0.1
CLASSPATH_LIB_BINARY:=$(CLASSPATH_DIR)/native/jni/java-lang/.libs/libjavalang.so.$(CLASSPATH_UGLY_VERSION)
CLASSPATH_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so
CLASSPATH_STARTLEVEL=40

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)

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

$(CLASSPATH_BINARY) $(CLASSPATH_LIB_BINARY): $(CLASSPATH_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(CLASSPATH_DIR)
	cp $(CLASSPATH_MAKE_DIR)/mini.classlist $(CLASSPATH_DIR)/lib;
	( cd $(CLASSPATH_DIR)/lib; fastjar -Mcf mini.jar -@ < mini.classlist );

$(CLASSPATH_TARGET_BINARY): $(CLASSPATH_BINARY)
	mkdir -p $(dir $(CLASSPATH_TARGET_BINARY))
	cp $(CLASSPATH_BINARY) $(CLASSPATH_TARGET_BINARY)

$(CLASSPATH_LIB_STAGING_BINARY): $(CLASSPATH_LIB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(CLASSPATH_DIR)/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavaio.la
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavalang.la
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavalangmanagement.la
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavalangreflect.la
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavanet.la
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavanio.la
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavautil.la
	touch -c $@

$(CLASSPATH_DIR)/.installed: $(CLASSPATH_LIB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjava*.so* root/usr/lib
	$(TARGET_STRIP) root/usr/lib/libjava*.so*
	touch $@

classpath:

classpath-precompiled: uclibc $(CLASSPATH_DIR)/.installed classpath $(CLASSPATH_TARGET_BINARY)

classpath-source: $(CLASSPATH_DIR)/.unpacked

classpath-clean:
	-$(MAKE) -C $(CLASSPATH_DIR) clean

classpath-dirclean:
	rm -rf $(CLASSPATH_DIR)
	rm -rf $(PACKAGES_DIR)/classpath-$(CLASSPATH_VERSION)
	rm -f $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)

classpath-uninstall:
	rm -f $(CLASSPATH_TARGET_BINARY)
	rm -rf root/usr/lib/libjava*.so*
	rm -f $(CLASSPATH_DIR)/.installed

$(PACKAGE_LIST)