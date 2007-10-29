PACKAGE_LC:=classpath
PACKAGE_UC:=CLASSPATH
$(PACKAGE_UC)_VERSION:=0.95
$(PACKAGE_INIT_BIN)
CLASSPATH_UGLY_VERSION:=0.0.0
CLASSPATH_SOURCE:=classpath-$(CLASSPATH_VERSION).tar.gz
CLASSPATH_SITE:=ftp://ftp.gnu.org/gnu/classpath
CLASSPATH_BINARY:=$(CLASSPATH_DIR)/lib/mini.jar
CLASSPATH_TARGET_BINARY:=$(CLASSPATH_DEST_DIR)/usr/share/classpath/mini.jar
CLASSPATH_LIB_BINARY:=$(CLASSPATH_DIR)/native/jni/java-lang/.libs/libjavalang.so.$(CLASSPATH_UGLY_VERSION)
CLASSPATH_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so

$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-gtk-peer
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-qt-peer
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-gconf-peer
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-plugin       
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-ecj               
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-Werror


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY) $($(PACKAGE_UC)_LIB_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(CLASSPATH_DIR)
	cp $(CLASSPATH_MAKE_DIR)/mini.classlist $(CLASSPATH_DIR)/lib;
	( cd $(CLASSPATH_DIR)/lib; fastjar -Mcf mini.jar -@ < mini.classlist );

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	mkdir -p $(dir $@)
	cp $(CLASSPATH_BINARY) $(CLASSPATH_TARGET_BINARY)

$($(PACKAGE_UC)_LIB_STAGING_BINARY): $($(PACKAGE_UC)_LIB_BINARY)
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

$($(PACKAGE_UC)_DIR)/.installed: $($(PACKAGE_UC)_LIB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjava*.so* $(ROOT_DIR)/usr/lib
	$(TARGET_STRIP) $(ROOT_DIR)/usr/lib/libjava*.so*
	touch $@

classpath:

classpath-precompiled: uclibc $($(PACKAGE_UC)_DIR)/.installed classpath $($(PACKAGE_UC)_TARGET_BINARY)

classpath-clean:
	-$(MAKE) -C $(CLASSPATH_DIR) clean

classpath-uninstall:
	rm -f $(CLASSPATH_TARGET_BINARY)
	rm -rf root/usr/lib/libjava*.so*
	rm -f $(CLASSPATH_DIR)/.installed

$(PACKAGE_FINI)