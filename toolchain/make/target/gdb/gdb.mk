######################################################################
#
# gdb
#
######################################################################
GDB_VERSION:=$(TARGET_TOOLCHAIN_GDB_VERSION)
GDB_SITE:=http://ftp.gnu.org/gnu/gdb
GDB_SOURCE:=gdb-$(GDB_VERSION).tar.bz2
GDB_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdb-$(GDB_VERSION)
GDB_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/gdb
GDB_STAGING_DIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/target-utils

$(GDB_STAGING_DIR):
	mkdir -p $(GDB_STAGING_DIR)

$(DL_DIR)/$(GDB_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(GDB_SOURCE) $(GDB_SITE)

gdb-unpacked: $(GDB_DIR)/.unpacked
$(GDB_DIR)/.unpacked: $(DL_DIR)/$(GDB_SOURCE)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(GDB_SOURCE)
	touch $@

gdb-patched: $(GDB_DIR)/.patched
$(GDB_DIR)/.patched: $(GDB_DIR)/.unpacked
	set -e; \
	for i in $(GDB_MAKE_DIR)/$(GDB_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(GDB_DIR) $$i; \
	done
	touch $@

gdb-source: $(DL_DIR)/$(GDB_SOURCE)

######################################################################
#
# gdb target
#
######################################################################

GDB_TARGET_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdb-$(GDB_VERSION)-target

GDB_TARGET_CONFIGURE_VARS:= \
	ac_cv_type_uintptr_t=yes \
	gt_cv_func_gettext_libintl=yes \
	ac_cv_func_dcgettext=yes \
	gdb_cv_func_sigsetjmp=yes \
	bash_cv_func_strcoll_broken=no \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_func_sigsetjmp=present \
	bash_cv_have_mbstate_t=yes

$(GDB_TARGET_DIR)/.configured: $(GDB_DIR)/.patched
	mkdir -p $(GDB_TARGET_DIR)
	(cd $(GDB_TARGET_DIR); PATH=$(TARGET_PATH) \
		gdb_cv_func_sigsetjmp=yes \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS)" \
		CPPFLAGS_FOR_TARGET="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS_FOR_TARGET="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		$(GDB_TARGET_CONFIGURE_VARS) \
		$(GDB_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--prefix=/usr \
		$(DISABLE_NLS) \
		--without-uiout $(DISABLE_GDBMI) \
		--disable-tui --disable-gdbtk --without-x \
		--disable-sim --enable-gdbserver \
		--without-included-gettext \
		--enable-threads \
		--disable-werror \
		$(QUIET) \
	);
ifeq ($(ENABLE_LOCALE),true)
	-$(SED) "s,^INTL *=.*,INTL = -lintl,g;" $(GDB_DIR)/gdb/Makefile
endif
	touch  $@

$(GDB_TARGET_DIR)/gdb/gdb: $(GDB_TARGET_DIR)/.configured
	PATH=$(TARGET_PATH) \
	    $(MAKE) CC=$(TARGET_CC) LDFLAGS="" \
	    MT_CFLAGS="$(TARGET_CFLAGS)" -C $(GDB_TARGET_DIR)

$(GDB_STAGING_DIR)/gdb: $(GDB_TARGET_DIR)/gdb/gdb | $(GDB_STAGING_DIR)
	$(INSTALL_BINARY_STRIP)
	
gdb_target: ncurses $(GDB_STAGING_DIR)/gdb

gdb_target-source: $(DL_DIR)/$(GDB_SOURCE)

gdb_target-clean:
	$(MAKE) -C $(GDB_DIR) clean

gdb_target-dirclean:
	rm -rf $(GDB_DIR)

######################################################################
#
# gdbserver
#
######################################################################

GDB_SERVER_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdbserver-$(GDB_VERSION)

$(GDB_SERVER_DIR)/.configured: $(GDB_DIR)/.patched
	mkdir -p $(GDB_SERVER_DIR)
	(cd $(GDB_SERVER_DIR); PATH=$(TARGET_PATH) \
		$(TARGET_CONFIGURE_OPTS) \
		gdb_cv_func_sigsetjmp=yes \
		bash_cv_have_mbstate_t=yes \
		$(GDB_DIR)/gdb/gdbserver/configure \
		--cache-file=/dev/null \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		--includedir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include \
		$(DISABLE_NLS) \
		--without-uiout $(DISABLE_GDBMI) \
		--disable-tui --disable-gdbtk --without-x \
		--without-included-gettext \
	);
	touch  $@

$(GDB_SERVER_DIR)/gdbserver: $(GDB_SERVER_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) CC=$(TARGET_CC) MT_CFLAGS="$(TARGET_CFLAGS)" \
		-C $(GDB_SERVER_DIR)
	
$(GDB_STAGING_DIR)/gdbserver: $(GDB_SERVER_DIR)/gdbserver | $(GDB_STAGING_DIR)
	$(INSTALL_BINARY_STRIP)

gdbserver: $(GDB_STAGING_DIR)/gdbserver

gdbserver-clean:
	$(MAKE) -C $(GDB_SERVER_DIR) clean

gdbserver-dirclean:
	rm -rf $(GDB_SERVER_DIR)

######################################################################
#
# gdb on host
#
######################################################################

GDB_HOST_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdbhost-$(GDB_VERSION)

$(GDB_HOST_DIR)/.configured: $(GDB_DIR)/.patched
	mkdir -p $(GDB_HOST_DIR)
	(cd $(GDB_HOST_DIR); PATH=$(TARGET_PATH) \
		gdb_cv_func_sigsetjmp=yes \
		bash_cv_have_mbstate_t=yes \
		$(GDB_DIR)/configure \
		--cache-file=/dev/null \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		$(DISABLE_NLS) \
		--without-uiout $(DISABLE_GDBMI) \
		--disable-tui --disable-gdbtk --without-x \
		--without-included-gettext \
		--enable-threads \
		--disable-werror \
	);
	touch  $@

$(GDB_HOST_DIR)/gdb/gdb: $(GDB_HOST_DIR)/.configured
	$(MAKE) -C $(GDB_HOST_DIR)
	strip $(GDB_HOST_DIR)/gdb/gdb

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(TARGET_CROSS)gdb: $(GDB_HOST_DIR)/gdb/gdb
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; \
	install -c $(GDB_HOST_DIR)/gdb/gdb $(TARGET_CROSS)gdb; \
	ln -fs $(TARGET_CROSS)gdb $(GNU_TARGET_NAME)-gdb; \
	);

gdbhost: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(TARGET_CROSS)gdb

gdbhost-clean:
	$(MAKE) -C $(GDB_HOST_DIR) clean

gdbhost-dirclean:
	rm -rf $(GDB_HOST_DIR)

gdb: uclibc $(GDB_TARGETS)

gdb-clean:
	-$(MAKE) -C $(GDB_HOST_DIR) clean
	-$(MAKE) -C $(GDB_SERVER_DIR) clean
	-$(MAKE) -C $(GDB_DIR) clean
	
gdb-dirclean:
	rm -rf $(GDB_DIR)
	rm -rf $(GDB_HOST_DIR)
	rm -rf $(GDB_SERVER_DIR)
	rm -rf $(GDB_DIR)

.PHONY: gdb gdbserver gdbtarget gdbhost gdb-unpacked
