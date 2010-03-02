$(call PKG_INIT_BIN, 0.97.2)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=classpath-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=6a35347901ace03c31cc49751b338f31
$(PKG)_SITE:=ftp://ftp.gnu.org/gnu/classpath

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/mini.jar
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/share/classpath/mini.jar

#TODO: FREETZ_LIBRARY_PATH !?
$(PKG)_LIBRARY_DIR:=/usr/lib/classpath
$(PKG)_LIBNAMES_SHORT:=io lang langmanagement langreflect net nio util
$(PKG)_LIBNAMES_LONG:=$(CLASSPATH_LIBNAMES_SHORT:%=libjava%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR_SHORT:=io lang lang lang net nio util
$(PKG)_LIBS_BUILD_DIR:=$(join $(CLASSPATH_LIBS_BUILD_DIR_SHORT:%=$($(PKG)_DIR)/native/jni/java-%/.libs/),$(CLASSPATH_LIBNAMES_LONG))
$(PKG)_LIBS_STAGING_DIR:=$(CLASSPATH_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$(CLASSPATH_LIBRARY_DIR)/%)
$(PKG)_LIBS_TARGET_DIR:=$(CLASSPATH_LIBNAMES_LONG:%=$($(PKG)_DEST_DIR)$(CLASSPATH_LIBRARY_DIR)/%)

$(PKG)_BUILD_PREREQ += fastjar ecj
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems this binaries are provided by packages of the same name

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON := libiconv
endif

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

$($(PKG)_BINARY) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CLASSPATH_DIR)
	cp $(CLASSPATH_MAKE_DIR)/mini.classlist $(CLASSPATH_DIR)/lib;
	( cd $(CLASSPATH_DIR)/lib; fastjar -Mcf mini.jar -@ < mini.classlist );

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(CLASSPATH_DIR)/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(PKG_FIX_LIBTOOL_LA) \
		$(CLASSPATH_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$(CLASSPATH_LIBRARY_DIR)/libjava%.la)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_DIR)$(CLASSPATH_LIBRARY_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)$(CLASSPATH_LIBRARY_DIR)/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CLASSPATH_DIR) clean

$(pkg)-uninstall:
	$(RM) \
		$(CLASSPATH_TARGET_BINARY) \
		$(CLASSPATH_DEST_DIR)$(CLASSPATH_LIBRARY_DIR)/libjava*.so*

$(PKG_FINISH)
