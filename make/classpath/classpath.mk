$(eval $(call PKG_INIT_BIN, 0.95))
$(PKG)_UGLY_VERSION:=0.0.0
$(PKG)_SOURCE:=classpath-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gnu.org/gnu/classpath
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/mini.jar
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/share/classpath/mini.jar
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/native/jni/java-lang/.libs/libjavalang.so.$($(PKG)_UGLY_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so

$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-peer
$(PKG)_CONFIGURE_OPTIONS += --disable-qt-peer
$(PKG)_CONFIGURE_OPTIONS += --disable-gconf-peer
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --disable-plugin       
$(PKG)_CONFIGURE_OPTIONS += --with-ecj               
$(PKG)_CONFIGURE_OPTIONS += --disable-Werror


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(CLASSPATH_DIR)
	cp $(CLASSPATH_MAKE_DIR)/mini.classlist $(CLASSPATH_DIR)/lib;
	( cd $(CLASSPATH_DIR)/lib; fastjar -Mcf mini.jar -@ < mini.classlist );

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(dir $@)
	cp $(CLASSPATH_BINARY) $(CLASSPATH_TARGET_BINARY)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(CLASSPATH_DIR)/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavaio.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavalang.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavalangmanagement.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavalangreflect.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavanet.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavanio.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/classpath/libjavautil.la
	touch -c $@

$($(PKG)_DIR)/.installed: $($(PKG)_LIB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjava*.so* $(ROOT_DIR)/usr/lib
	$(TARGET_STRIP) $(ROOT_DIR)/usr/lib/libjava*.so*
	touch $@

classpath:

classpath-precompiled: uclibc $($(PKG)_DIR)/.installed classpath $($(PKG)_TARGET_BINARY)

classpath-clean:
	-$(MAKE) -C $(CLASSPATH_DIR) clean

classpath-uninstall:
	rm -f $(CLASSPATH_TARGET_BINARY)
	rm -rf root/usr/lib/libjava*.so*
	rm -f $(CLASSPATH_DIR)/.installed

$(PKG_FINISH)