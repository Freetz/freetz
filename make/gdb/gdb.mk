$(call PKG_INIT_BIN, $(if $(FREETZ_GDB_VERSION_6_8),6.8,7.8))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)$(if $(FREETZ_GDB_VERSION_6_8),a).tar.$(if $(FREETZ_GDB_VERSION_6_8),bz2,xz)
$(PKG)_SOURCE_MD5_6.8 := da20d043e6729f74b909bd507bcae5c9
$(PKG)_SOURCE_MD5_7.8 := bd958fe9019d7c7896f29f6724a764ed
$(PKG)_SOURCE_MD5     := $($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))
$(PKG)_SITE:=@GNU/gdb
$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_DEPENDS_ON += ncurses readline

$(PKG)_BINARIES_ALL           := gdb  gdbserver
$(PKG)_BINARIES_BUILD_SUBDIRS := gdb/ gdb/gdbserver/
$(PKG)_BINARIES               := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR     := $(addprefix $($(PKG)_DIR)/, $(join $($(PKG)_BINARIES_BUILD_SUBDIRS),$($(PKG)_BINARIES_ALL)))
$(PKG)_BINARIES_TARGET_DIR    := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_NOT_INCLUDED           := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_CATEGORY:=Debug helpers

$(PKG)_REBUILD_SUBOPTS += FREETZ_GDB_VERSION_6_8
$(PKG)_REBUILD_SUBOPTS += FREETZ_GDB_VERSION_7_8

$(PKG)_CONFIGURE_ENV += bash_cv_func_strcoll_broken=no
$(PKG)_CONFIGURE_ENV += bash_cv_must_reinstall_sighandlers=no
$(PKG)_CONFIGURE_ENV += bash_cv_func_sigsetjmp=present
$(PKG)_CONFIGURE_ENV += bash_cv_have_mbstate_t=yes

$(PKG)_CONFIGURE_ENV += CFLAGS_FOR_TARGET="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += CPPFLAGS_FOR_TARGET="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_ENV += LDFLAGS_FOR_TARGET="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

$(PKG)_CONFIGURE_OPTIONS += --enable-gdbserver
$(PKG)_CONFIGURE_OPTIONS += --enable-threads
$(PKG)_CONFIGURE_OPTIONS += --disable-tui
$(PKG)_CONFIGURE_OPTIONS += --disable-gdbtk
$(PKG)_CONFIGURE_OPTIONS += --disable-sim
$(PKG)_CONFIGURE_OPTIONS += --disable-werror

$(PKG)_CONFIGURE_OPTIONS += --with-system-readline=yes
$(PKG)_CONFIGURE_OPTIONS += --without-expat
$(PKG)_CONFIGURE_OPTIONS += --without-included-gettext
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-tcl
$(PKG)_CONFIGURE_OPTIONS += --without-tk
$(PKG)_CONFIGURE_OPTIONS += --without-uiout
$(PKG)_CONFIGURE_OPTIONS += --without-x
$(PKG)_CONFIGURE_OPTIONS += --without-zlib

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GDB_DIR) \
		MT_CFLAGS="$(TARGET_CFLAGS)"

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GDB_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GDB_BINARIES_ALL:%=$(GDB_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)

####################################################################################
#
# gdb for host
#
####################################################################################
GDB_HOST_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdbhost-$(GDB_VERSION)
GDB_HOST_BINARY_BUILDDIR:=$(GDB_HOST_DIR)/gdb/gdb
GDB_HOST_BINARY_DESTDIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(TARGET_CROSS)gdb

$(GDB_HOST_DIR)/.configured: | $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_HOST_DIR)
	(cd $(GDB_HOST_DIR); PATH=$(TARGET_PATH) \
		$(FREETZ_BASE_DIR)/$(GDB_DIR)/configure \
		--cache-file=/dev/null \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		$(DISABLE_NLS) \
		--enable-threads \
		--disable-tui \
		--disable-gdbtk \
		--disable-werror \
		--without-uiout \
		--without-x \
		--without-included-gettext \
	);
	touch $@

$(GDB_HOST_BINARY_BUILDDIR): $(GDB_HOST_DIR)/.configured
	$(MAKE) -C $(GDB_HOST_DIR)
	strip $(GDB_HOST_BINARY_BUILDDIR)

$(GDB_HOST_BINARY_DESTDIR): $(GDB_HOST_BINARY_BUILDDIR)
	$(INSTALL_FILE)
	ln -sf $(TARGET_CROSS)gdb $(dir $@)/$(GNU_TARGET_NAME)-gdb

gdbhost: $(GDB_HOST_BINARY_DESTDIR)

gdbhost-clean:
	-$(MAKE) -C $(GDB_HOST_DIR) clean

gdbhost-uninstall:
	$(RM) $(GDB_HOST_BINARY_DESTDIR)

gdbhost-dirclean: gdbhost-uninstall
	$(RM) -r $(GDB_HOST_DIR)

.PHONY: gdbhost gdbhost-clean gdbhost-uninstall gdbhost-dirclean
