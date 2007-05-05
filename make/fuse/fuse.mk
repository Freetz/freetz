FUSE_VERSION:=2.6.5
FUSE_SOURCE:=fuse-$(FUSE_VERSION).tar.gz
FUSE_SITE:=http://mesh.dl.sourceforge.net/sourceforge/fuse
FUSE_DIR:=$(SOURCE_DIR)/fuse-$(FUSE_VERSION)
FUSE_MAKE_DIR:=$(MAKE_DIR)/fuse
FUSE_PKG_NAME:=fuse-$(FUSE_VERSION)
FUSE_PKG_VERSION:=0.1
FUSE_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
FUSE_PKG_SOURCE:=fuse-$(FUSE_VERSION)-dsmod-$(FUSE_PKG_VERSION).tar.bz2
FUSE_TARGET_BINARY:=fusermount
FUSE_TARGET_DIR:=$(PACKAGES_DIR)/$(FUSE_PKG_NAME)/root/usr/sbin

$(DL_DIR)/$(FUSE_SOURCE):
	wget -P $(DL_DIR) $(FUSE_SITE)/$(FUSE_SOURCE)
	
$(DL_DIR)/$(FUSE_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(FUSE_PKG_SOURCE) $(FUSE_PKG_SITE)

$(FUSE_DIR)/.unpacked: $(DL_DIR)/$(FUSE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FUSE_SOURCE)
	for i in $(FUSE_MAKE_DIR)/patches/*.patch; do \
		patch -d $(FUSE_DIR) -p0 < $$i; \
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
		LDFLAGS="-static-libgcc" \
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

$(FUSE_DIR)/.compiled: $(FUSE_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) $(MAKE) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		-C $(FUSE_DIR) all
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so: $(FUSE_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH):$(KERNEL_MAKE_PATH) $(MAKE) \
		-C $(FUSE_DIR) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

$(FUSE_TARGET_DIR)/$(FUSE_TARGET_BINARY): $(FUSE_DIR)/.compiled $(PACKAGES_DIR)/.$(FUSE_PKG_NAME)
	$(TARGET_STRIP) $(FUSE_DIR)/util/$(FUSE_TARGET_BINARY)
	cp $(FUSE_DIR)/util/$(FUSE_TARGET_BINARY) $(FUSE_TARGET_DIR)/$(FUSE_TARGET_BINARY)
	touch -c $@ 

$(KERNEL_MODULES_DIR)/lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/kernel/fs/fuse: $(FUSE_DIR)/.compiled
	mkdir -p $(KERNEL_TARGET_DIR)/modules-$(KERNEL_REF)-$(AVM_VERSION)/lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/kernel/fs/fuse
	cp -a $(FUSE_DIR)/kernel/fuse.ko $(KERNEL_MODULES_DIR)/lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/kernel/fs/fuse

$(PACKAGES_DIR)/.$(FUSE_PKG_NAME): $(DL_DIR)/$(FUSE_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(FUSE_PKG_SOURCE)
	@touch $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
fuse fuse-precompiled: $(PACKAGES_DIR)/.$(FUSE_PKG_NAME) \
		       $(FUSE_TARGET_DIR)/$(FUSE_TARGET_BINARY) \
		       $(KERNEL_MODULES_DIR)/lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/kernel/fs/fuse
	@echo 'External compiler used. Trying to copy libfuse from external Toolchain...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libfuse*.so* root/usr/lib/

else
fuse:	$(PACKAGES_DIR)/.$(FUSE_PKG_NAME) \
	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so \
	$(FUSE_TARGET_DIR)/$(FUSE_TARGET_BINARY) \
	$(KERNEL_MODULES_DIR)/lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/kernel/fs/fuse
	
fuse-precompiled: uclibc fuse
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so* root/usr/lib/
endif

fuse-package: $(PACKAGES_DIR)/.$(FUSE_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(FUSE_PKG_SOURCE) $(FUSE_PKG_NAME)

fuse-source: $(FUSE_DIR)/.unpacked $(PACKAGES_DIR)/.$(FUSE_PKG_NAME)

fuse-clean:
	-$(MAKE) -C $(FUSE_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(FUSE_PKG_SOURCE)
	
fuse-uninstall:
	rm -rf root/usr/lib/libfuse*.so*

fuse-dirclean:
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so.*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.a
	rm -rf $(FUSE_DIR)
	rm -rf $(PACKAGES_DIR)/$(FUSE_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(FUSE_PKG_NAME)

fuse-list:
ifeq ($(strip $(DS_PACKAGE_FUSE)),y)
	@echo "S40fuse-$(FUSE_VERSION)" >> .static
else
	@echo "S40fuse-$(FUSE_VERSION)" >> .dynamic
endif