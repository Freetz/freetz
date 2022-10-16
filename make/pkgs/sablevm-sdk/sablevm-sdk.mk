$(call PKG_INIT_BIN, 1.13)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=bcda3aa3efb30fef3ef61c7bbabdb262f92a2d22649d187a06a28ddecc3b93b9
$(PKG)_SITE:=@SF/sablevm

$(PKG)_BINARY:=$($(PKG)_DIR)/sablevm/src/sablevm/.libs/sablevm
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sablevm

$(PKG)_LIB_CLASSPATH_MINI:=$($(PKG)_DIR)/sablevm-classpath/lib/mini.jar
$(PKG)_LIB_CLASSPATH_ORIG:=$($(PKG)_DIR)/sablevm-classpath/lib/libclasspath.jar
$(PKG)_LIB_TARGET_CLASSPATH:=$($(PKG)_DEST_DIR)/usr/share/sablevm-classpath/libclasspath.jar

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/sablevm/src/libsablevm/.libs/libsablevm-$($(PKG)_VERSION).so
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libsablevm-$($(PKG)_VERSION).so

$(PKG)_LIB_CLASSPATH_BINARY:=$($(PKG)_DIR)/sablevm-classpath/native/jni/java-io/.libs/libjavaio-$($(PKG)_VERSION).so
$(PKG)_LIB_STAGING_CLASSPATH_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavaio-$($(PKG)_VERSION).so
$(PKG)_LIB_TARGET_CLASSPATH_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/sablevm-classpath/libjavaio-$($(PKG)_VERSION).so

$(PKG)_DEPENDS_ON += libffi libtool popt zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SABLEVM_SDK_MINI

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,configure sablevm/configure sablevm/src/libffi/configure sablevm-classpath/configure)

$(PKG)_COMMON_CONFIGURE_OPTIONS += --enable-static
$(PKG)_COMMON_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_COMMON_CONFIGURE_OPTIONS += --disable-rpath

$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_COMMON_CONFIGURE_OPTIONS)
$(PKG)_CONFIGURE_OPTIONS += --disable-cp-tools
$(PKG)_CONFIGURE_OPTIONS += --disable-gjdoc

$(PKG)_CONFIGURE_OPTIONS += --with-jikes=internal
$(PKG)_CONFIGURE_OPTIONS += --with-fastjar=internal
$(PKG)_INTERNAL_JIKES    := "$(FREETZ_BASE_DIR)/$($(PKG)_DIR)/bin/jikes"
$(PKG)_INTERNAL_FASTJAR  := "$(FREETZ_BASE_DIR)/$($(PKG)_DIR)/bin/fastjar"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

define SABLEVM_SDK_HOST_DEPENDENCY
$($(PKG)_DIR)/$(1)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(SABLEVM_SDK_DIR)/$(1); $(RM) config.cache; ./configure --prefix="$(FREETZ_BASE_DIR)/$(SABLEVM_SDK_DIR)/_dummyprefix");
	touch $$@

$($(PKG)_DIR)/$(1)/.compiled: $($(PKG)_DIR)/$(1)/.configured
	$(MAKE) -C $(SABLEVM_SDK_DIR)/$(1)
	touch $$@
endef

$(eval $(call SABLEVM_SDK_HOST_DEPENDENCY,jikes))
$(eval $(call SABLEVM_SDK_HOST_DEPENDENCY,fastjar))

$(PKG_CONFIGURED_CONFIGURE)
$($(PKG)_DIR)/.configured $($(PKG)_DIR)/sablevm/.configured $($(PKG)_DIR)/sablevm-classpath/.configured : $($(PKG)_DIR)/jikes/.compiled $($(PKG)_DIR)/fastjar/.compiled

$($(PKG)_DIR)/sablevm/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(SABLEVM_SDK_DIR)/sablevm; $(RM) config.cache; \
		$(TARGET_CONFIGURE_ENV) \
		./configure \
		$(TARGET_CONFIGURE_OPTIONS) \
		$(SABLEVM_SDK_COMMON_CONFIGURE_OPTIONS) \
		--with-jikes="$(SABLEVM_SDK_INTERNAL_JIKES)" \
		--with-fastjar="$(SABLEVM_SDK_INTERNAL_FASTJAR)" \
		--with-internal-libffi=no \
		--with-internal-libpopt=no \
	);
	touch $@

$($(PKG)_DIR)/sablevm-classpath/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(SABLEVM_SDK_DIR)/sablevm-classpath; $(RM) config.cache; \
		$(TARGET_CONFIGURE_ENV) \
		./configure \
		$(TARGET_CONFIGURE_OPTIONS) \
		$(SABLEVM_SDK_COMMON_CONFIGURE_OPTIONS) \
		--with-jikes="$(SABLEVM_SDK_INTERNAL_JIKES)" \
		--with-fastjar="$(SABLEVM_SDK_INTERNAL_FASTJAR)" \
		--disable-gtk-peer \
		--disable-gtk-cairo \
		--without-x \
	);
	touch $@

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured $($(PKG)_DIR)/sablevm/.configured $($(PKG)_DIR)/sablevm-classpath/.configured
	$(SUBMAKE) -C $(SABLEVM_SDK_DIR) all \
		EARLY_CONFIGURE= \
		EXTRA_CONFIGURE=
	cp $(SABLEVM_SDK_MAKE_DIR)/mini.classlist $(SABLEVM_SDK_DIR)/sablevm-classpath/lib/
	(cd $(SABLEVM_SDK_DIR)/sablevm-classpath/lib; "$(SABLEVM_SDK_INTERNAL_FASTJAR)" -Mcf mini.jar -@ < mini.classlist;)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_STAGING_CLASSPATH_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(SABLEVM_SDK_DIR)/sablevm-classpath/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavaio.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavalang.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavalangreflect.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavanet.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavanio.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sablevm-classpath/libjavautil.la

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_BINARY)
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

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
	-$(SUBMAKE) -C $(SABLEVM_SDK_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SABLEVM_SDK_TARGET_BINARY)
	$(RM) $(SABLEVM_SDK_DEST_LIBDIR)/libsablevm*.so*
	$(RM) $(SABLEVM_SDK_DEST_DIR)/usr/lib/sablevm-classpath/libjava*.so*
	$(RM) $(SABLEVM_SDK_DEST_DIR)/usr/share/sablevm-classpath/*

$(PKG_FINISH)
