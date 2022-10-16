$(call PKG_INIT_BIN, 10.35.85)
$(PKG)_LIB_VERSION:=10.35
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_HASH:=393834df6b2d7a8e62a9b1ec7ac56b48e82b3192503d2e3956373181fcc365e5
$(PKG)_SITE:=@SF/netpbm/super_stable/$($(PKG)_VERSION)

$(PKG)_LIBNAME := libnetpbm.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_BUILD_DIR := $($(PKG)_DIR)/lib/$($(PKG)_LIBNAME)
$(PKG)_LIB_STAGING_DIR := $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_LIB_TARGET_DIR := $($(PKG)_TARGET_LIBDIR)/$($(PKG)_LIBNAME)

# see INTERFACE_HEADERS variable in lib/Makefile
$(PKG)_INTERFACE_HEADERS = \
	pm_config.h \
	lib/pm.h lib/pbm.h lib/bitio.h lib/pbmfont.h \
	lib/pgm.h lib/ppm.h lib/ppm.h lib/ppmcmap.h lib/ppmfloyd.h lib/colorname.h \
	lib/pnm.h lib/pam.h lib/pammap.h lib/pm_system.h lib/pm_gamma.h \
	lib/util/shhopt.h lib/util/nstring.h lib/util/mallocvar.h

$(PKG)_BINARIES_ALL := bmptopnm giftopnm jpegtopnm pngtopnm pnmtojpeg pnmtopng
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/converter/other/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON += jpeg
$(PKG)_DEPENDS_ON += libpng
$(PKG)_DEPENDS_ON += zlib

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

#NB: we do want to compile buildtools for the system netpbm is being built on, not for the target
$($(PKG)_DIR)/buildtools/.compiled: $($(PKG)_DIR)/.configured
	$(MAKE1) -C $(NETPBM_DIR)/buildtools all && touch $@

$($(PKG)_DIR)/Makefile.depend: $($(PKG)_DIR)/buildtools/.compiled
	$(SUBMAKE1) -C $(NETPBM_DIR) \
		FAKEROOTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		TARGET_CROSS_PREFIX="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		dep

$($(PKG)_LIB_BUILD_DIR): $($(PKG)_DIR)/Makefile.depend
	$(SUBMAKE1) -C $(NETPBM_DIR)/lib \
		FAKEROOTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		TARGET_CROSS_PREFIX="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC)" \
		all

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/converter/other/%: $($(PKG)_DIR)/Makefile.depend $($(PKG)_LIB_BUILD_DIR)
	$(SUBMAKE1) -C $(NETPBM_DIR)/converter/other \
		FAKEROOTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		TARGET_CROSS_PREFIX="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		$(notdir $@)

$($(PKG)_LIB_STAGING_DIR): $($(PKG)_LIB_BUILD_DIR)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/netpbm/ \
	&& cp -a $(NETPBM_INTERFACE_HEADERS:%=$(NETPBM_DIR)/%) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/netpbm/
	$(INSTALL_LIBRARY_INCLUDE_STATIC)

$($(PKG)_LIB_TARGET_DIR): $($(PKG)_LIB_STAGING_DIR)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/converter/other/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIB_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(NETPBM_DIR)/lib clean
	-$(SUBMAKE1) -C $(NETPBM_DIR)/converter/other clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/netpbm/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libnetpbm*

$(pkg)-uninstall:
	$(RM) \
		$(NETPBM_BINARIES_ALL:%=$(NETPBM_DEST_DIR)/usr/bin/%) \
		$(NETPBM_TARGET_LIBDIR)/libnetpbm*

$(call PKG_ADD_LIB,libnetpbm)
$(PKG_FINISH)
