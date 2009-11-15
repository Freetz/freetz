$(call PKG_INIT_BIN, 1.13)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/sablevm
$(PKG)_BINARY:=$($(PKG)_DIR)/sablevm/src/sablevm/.libs/sablevm
$(PKG)_LIB_CLASSPATH_MINI:=$($(PKG)_DIR)/sablevm-classpath/lib/mini.jar
$(PKG)_LIB_CLASSPATH_ORIG:=$($(PKG)_DIR)/sablevm-classpath/lib/mini.jar
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/sablevm/src/libsablevm/.libs/libsablevm-$($(PKG)_VERSION).so
$(PKG)_LIB_CLASSPATH_BINARY:=$($(PKG)_DIR)/sablevm-classpath/native/jni/java-io/.libs/libjavaio-$($(PKG)_VERSION).so
$(PKG)_LIB_STAGING_CLASSPATH_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavaio-$($(PKG)_VERSION).so
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sablevm
$(PKG)_LIB_TARGET_CLASSPATH:=$($(PKG)_DEST_DIR)/usr/share/sablevm-classpath/libclasspath.jar
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/libsablevm-$($(PKG)_VERSION).so
$(PKG)_LIB_TARGET_CLASSPATH_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/sablevm-classpath/libjavaio-$($(PKG)_VERSION).so
$(PKG)_SOURCE_MD5:=18a7c1a92b0748a206f9767a76a6b3bb

$(PKG)_DEPENDS_ON := libtool popt zlib

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SABLEVM_SDK_MINI

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-cp-tools
$(PKG)_CONFIGURE_OPTIONS += --disable-gjdoc

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/sablevm/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(SABLEVM_SDK_DIR)/sablevm; rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--cache-file=$(FREETZ_BASE_DIR)/$(MAKE_DIR)/config.cache \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--enable-static \
		--enable-shared \
		--srcdir="./../sablevm" \
		--with-internal-libffi=yes \
		--with-internal-libpopt=no \
	);
	touch $@

$($(PKG)_DIR)/sablevm-classpath/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(SABLEVM_SDK_DIR)/sablevm-classpath; rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--cache-file=$(FREETZ_BASE_DIR)/$(MAKE_DIR)/config.cache \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--enable-static \
		--enable-shared \
		--srcdir="./../sablevm-classpath" \
		--disable-gtk-peer \
		--disable-gtk-cairo \
		--without-x \
	);
	touch $@

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured \
	$($(PKG)_DIR)/sablevm/.configured $($(PKG)_DIR)/sablevm-classpath/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(SABLEVM_SDK_DIR) all \
		EARLY_CONFIGURE= \
		EXTRA_CONFIGURE=
	cp $(SABLEVM_SDK_MAKE_DIR)/mini.classlist $(SABLEVM_SDK_DIR)/sablevm-classpath/lib/
	( cd $(SABLEVM_SDK_DIR)/sablevm-classpath/lib;\
		fastjar -Mcf mini.jar -@ < mini.classlist ; \
	)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_STAGING_CLASSPATH_BINARY): $($(PKG)_LIB_BINARY)
	PATH=$(TARGET_PATH) $(MAKE) -C $(SABLEVM_SDK_DIR)/sablevm-classpath/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavaio.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavalang.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavalangreflect.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavanet.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavanio.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavautil.la

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_BINARY)
	cp -a $(SABLEVM_SDK_DIR)/sablevm/src/libsablevm/.libs/libsablevm*.so $(SABLEVM_SDK_DEST_DIR)/usr/lib
	$(TARGET_STRIP) $@

$($(PKG)_LIB_TARGET_CLASSPATH_BINARY): $($(PKG)_LIB_STAGING_CLASSPATH_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjava*.so* $(SABLEVM_SDK_DEST_DIR)/usr/lib/sablevm-classpath/
	$(TARGET_STRIP) $(SABLEVM_SDK_DEST_DIR)/usr/lib/sablevm-classpath/libjava*.so*
	cp $(SABLEVM_SDK_DIR)/sablevm-classpath/lib/resources.jar $(SABLEVM_SDK_DEST_DIR)/usr/share/sablevm-classpath/
ifeq ($(strip $(FREETZ_PACKAGE_SABLEVM_SDK_MINI)),y)
	cp $(SABLEVM_SDK_LIB_CLASSPATH_MINI) $(SABLEVM_SDK_LIB_TARGET_CLASSPATH)
else
	cp $(SABLEVM_SDK_LIB_CLASSPATH_ORIG) $(SABLEVM_SDK_LIB_TARGET_CLASSPATH)
endif
	touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY) $($(PKG)_LIB_TARGET_CLASSPATH_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SABLEVM_SDK_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SABLEVM_SDK_TARGET_BINARY)
	$(RM) $(SABLEVM_SDK_DEST_DIR)/usr/lib/libsablevm*.so*
	$(RM) $(SABLEVM_SDK_DEST_DIR)/usr/lib/sablevm-classpath/libjava*.so*
	$(RM) $(SABLEVM_SDK_DEST_DIR)/usr/share/sablevm-classpath/*

$(PKG_FINISH)
