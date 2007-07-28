FUSE_VERSION:=2.7.0
FUSE_SOURCE:=fuse-$(FUSE_VERSION).tar.gz
FUSE_SITE:=http://mesh.dl.sourceforge.net/sourceforge/fuse
FUSE_MAKE_DIR:=$(MAKE_DIR)/fuse
FUSE_PKG_NAME:=fuse-$(FUSE_VERSION)
FUSE_PKG_VERSION:=0.1
FUSE_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
FUSE_PKG_SOURCE:=fuse-$(FUSE_VERSION)-dsmod-$(FUSE_PKG_VERSION).tar.bz2
FUSE_DIR:=$(SOURCE_DIR)/fuse-$(FUSE_VERSION)
FUSE_BINARY:=$(FUSE_DIR)/util/fusermount
FUSE_TARGET_DIR:=$(PACKAGES_DIR)/$(FUSE_PKG_NAME)
FUSE_TARGET_BINARY:=$(FUSE_TARGET_DIR)/root/usr/sbin/fusermount
FUSE_MOD_BINARY:=$(FUSE_DIR)/kernel/fuse.ko
FUSE_MOD_TARGET_DIR:=$(KERNEL_MODULES_DIR)/lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/kernel/fs/fuse
FUSE_MOD_TARGET_BINARY:=$(FUSE_MOD_TARGET_DIR)/fuse.ko
FUSE_LIB_BINARY:=$(FUSE_DIR)/lib/.libs/libfuse.so.$(FUSE_VERSION)
FUSE_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so.$(FUSE_VERSION)
FUSE_LIB_TARGET_BINARY:=$(FUSE_TARGET_DIR)/root/usr/lib/libfuse.so.$(FUSE_VERSION)

$(DL_DIR)/$(FUSE_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(FUSE_SITE)/$(FUSE_SOURCE)

$(DL_DIR)/$(FUSE_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(FUSE_PKG_SOURCE) $(FUSE_PKG_SITE)

$(FUSE_DIR)/.unpacked: $(DL_DIR)/$(FUSE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FUSE_SOURCE)
	for i in $(FUSE_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(FUSE_DIR) $$i 0; \
	done
	touch $@

$(FUSE_DIR)/.configured: $(FUSE_DIR)/.unpacked
	( cd $(FUSE_DIR); rm -f config.cache; \
		touch configure.in ; \
		touch aclocal.m4 ; \
		touch Makefile.in ; \
		touch include/config.h.in ; \
		touch configure ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		./configure \
			--target=$(GNU_TARGET_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--program-prefix="" \
			--program-suffix="" \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--datadir=/usr/share \
			--includedir=/usr/include \
			--infodir=/usr/share/info \
			--libdir=/usr/lib \
			--libexecdir=/usr/lib \
			--localstatedir=/var \
			--mandir=/usr/share/man \
			--sbindir=/usr/sbin \
			--sysconfdir=/etc \
			$(DISABLE_LARGEFILE) \
			$(DISABLE_NLS) \
			--enable-shared \
			--enable-static \
			--disable-rpath \
			--enable-kernel-module \
			--enable-lib \
			--enable-util \
			--disable-example \
			--disable-auto-modprobe \
			--with-kernel="$(shell pwd)/$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/" \
			--disable-mtab \
	);
	touch $@

$(FUSE_BINARY) $(FUSE_MOD_BINARY) $(FUSE_LIB_BINARY): $(FUSE_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) \
		$(MAKE) -C $(FUSE_DIR) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		all

$(FUSE_LIB_STAGING_BINARY): $(FUSE_LIB_BINARY)
	cp $(FUSE_DIR)/fuse.pc $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/fuse.pc
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) $(MAKE) \
		-C $(FUSE_DIR)/lib \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) $(MAKE) \
		-C $(FUSE_DIR)/include \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(PACKAGES_DIR)/.$(FUSE_PKG_NAME): $(DL_DIR)/$(FUSE_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(FUSE_PKG_SOURCE)
	@touch $@

$(FUSE_TARGET_BINARY): $(FUSE_BINARY)
	$(INSTALL_BINARY_STRIP)

$(FUSE_MOD_TARGET_BINARY): $(FUSE_MOD_BINARY)
	mkdir -p $(FUSE_MOD_TARGET_DIR)
	cp $^ $@

$(FUSE_LIB_TARGET_BINARY): $(FUSE_LIB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so* $(FUSE_TARGET_DIR)/root/usr/lib
	$(TARGET_STRIP) $@

fuse: $(PACKAGES_DIR)/.$(FUSE_PKG_NAME)

fuse-precompiled: uclibc fuse $(FUSE_TARGET_BINARY) $(FUSE_MOD_TARGET_BINARY) $(FUSE_LIB_TARGET_BINARY)

fuse-package: $(PACKAGES_DIR)/.$(FUSE_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(FUSE_PKG_SOURCE) $(FUSE_PKG_NAME)

fuse-source: $(FUSE_DIR)/.unpacked $(PACKAGES_DIR)/.$(FUSE_PKG_NAME)

fuse-clean:
	-$(MAKE) -C $(FUSE_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(FUSE_PKG_SOURCE) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/fuse.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ulockmgr.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fuse* \
        $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*

fuse-dirclean:
	rm -rf $(FUSE_DIR)
	rm -rf $(PACKAGES_DIR)/$(FUSE_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(FUSE_PKG_NAME)

fuse-uninstall:
	rm -f $(FUSE_TARGET_BINARY)
	rm -f $(FUSE_MOD_TARGET_BINARY)
	rm -f $(FUSE_TARGET_DIR)/root/usr/lib/libfuse*.so*

fuse-list:
ifeq ($(strip $(DS_PACKAGE_FUSE)),y)
	@echo "S40fuse-$(FUSE_VERSION)" >> .static
else
	@echo "S40fuse-$(FUSE_VERSION)" >> .dynamic
endif
