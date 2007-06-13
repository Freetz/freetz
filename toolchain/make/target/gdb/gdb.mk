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

# NOTE: This option should not be used with newer gdb versions.
#DISABLE_GDBMI:=--disable-gdbmi

$(DL_DIR)/$(GDB_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(GDB_SITE)/$(GDB_SOURCE)

gdb-unpacked: $(GDB_DIR)/.unpacked
$(GDB_DIR)/.unpacked: $(DL_DIR)/$(GDB_SOURCE)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(GDB_SOURCE)
	for i in $(GDB_MAKE_DIR)/$(GDB_VERSION)/*.patch; do \
		patch -d $(GDB_DIR) -p1 < $$i; \
	done
	# Copy a config.sub from gcc.  This is only necessary until
	# gdb's config.sub supports <arch>-linux-uclibc tuples.
	# Should probably integrate this into the patch.
	touch  $(GDB_DIR)/.unpacked

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

$(GDB_TARGET_DIR)/.configured: $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_TARGET_DIR)
	(cd $(GDB_TARGET_DIR); PATH=$(TARGET_TOOLCHAIN_PATH) \
		gdb_cv_func_sigsetjmp=yes \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS)" \
		CPPFLAGS_FOR_TARGET="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS_FOR_TARGET="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		$(GDB_TARGET_CONFIGURE_VARS) \
		$(GDB_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/target-utils \
		$(DISABLE_NLS) \
		--without-uiout $(DISABLE_GDBMI) \
		--disable-tui --disable-gdbtk --without-x \
		--disable-sim --enable-gdbserver \
		--without-included-gettext \
	);
ifeq ($(ENABLE_LOCALE),true)
	-$(SED) "s,^INTL *=.*,INTL = -lintl,g;" $(GDB_DIR)/gdb/Makefile
endif
	touch  $(GDB_TARGET_DIR)/.configured

$(GDB_TARGET_DIR)/gdb/gdb: $(GDB_TARGET_DIR)/.configured
	PATH=$(TARGET_PATH) \
	    $(MAKE) CC=$(TARGET_CC) LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
	    MT_CFLAGS="$(TARGET_CFLAGS)" -C $(GDB_TARGET_DIR)
	$(TARGET_STRIP) $(GDB_TARGET_DIR)/gdb/gdb

$(TARGET_TOOLCHAIN_STAGING_DIR)/target-utils/gdb: $(GDB_TARGET_DIR)/gdb/gdb
	install -c -D $(GDB_TARGET_DIR)/gdb/gdb $@
	

gdb_target: ncurses $(TARGET_TOOLCHAIN_STAGING_DIR)/target-utils/bin/gdb

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

$(GDB_SERVER_DIR)/.configured: $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_SERVER_DIR)
	(cd $(GDB_SERVER_DIR); PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(TARGET_CONFIGURE_OPTS) \
		gdb_cv_func_sigsetjmp=yes \
		$(GDB_DIR)/gdb/gdbserver/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		$(DISABLE_NLS) \
		--without-uiout $(DISABLE_GDBMI) \
		--disable-tui --disable-gdbtk --without-x \
		--without-included-gettext \
	);
	touch  $(GDB_SERVER_DIR)/.configured

$(GDB_SERVER_DIR)/gdbserver: $(GDB_SERVER_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) MT_CFLAGS="$(TARGET_CFLAGS)" \
		-C $(GDB_SERVER_DIR)
	$(TARGET_STRIP) $(GDB_SERVER_DIR)/gdbserver
	
$(TARGET_TOOLCHAIN_STAGING_DIR)/target-utils/gdbserver: $(GDB_SERVER_DIR)/gdbserver
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/target-utils
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/target-utils; \
	install -c $(GDB_SERVER_DIR)/gdbserver gdbserver; \
	);

gdbserver: $(TARGET_TOOLCHAIN_STAGING_DIR)/target-utils/gdbserver

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

$(GDB_HOST_DIR)/.configured: $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_HOST_DIR)
	(cd $(GDB_HOST_DIR); PATH=$(TARGET_TOOLCHAIN_PATH) \
		gdb_cv_func_sigsetjmp=yes \
		$(GDB_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		$(DISABLE_NLS) \
		--without-uiout $(DISABLE_GDBMI) \
		--disable-tui --disable-gdbtk --without-x \
		--without-included-gettext \
		--enable-threads \
	);
	touch  $(GDB_HOST_DIR)/.configured

$(GDB_HOST_DIR)/gdb/gdb: $(GDB_HOST_DIR)/.configured
	$(MAKE) -C $(GDB_HOST_DIR)
	strip $(GDB_HOST_DIR)/gdb/gdb

$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(TARGET_CROSS)gdb: $(GDB_HOST_DIR)/gdb/gdb
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; \
	install -c $(GDB_HOST_DIR)/gdb/gdb $(TARGET_CROSS)gdb; \
	ln -fs $(TARGET_CROSS)gdb $(GNU_TARGET_NAME)-gdb; \
	);

gdbhost: $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(TARGET_CROSS)gdb

gdbhost-clean:
	$(MAKE) -C $(GDB_HOST_DIR) clean

gdbhost-dirclean:
	rm -rf $(GDB_HOST_DIR)

gdb: uclibc $(TARGETS)

gdb-clean:
	-$(MAKE) -C $(GDB_HOST_DIR) clean
	-$(MAKE) -C $(GDB_SERVER_DIR) clean
	-$(MAKE) -C $(GDB_DIR) clean
	
gdb-dirclean:
	rm -rf $(GDB_DIR)
	rm -rf $(GDB_HOST_DIR)
	rm -rf $(GDB_SERVER_DIR)
	rm -rf $(GDB_DIR)
	