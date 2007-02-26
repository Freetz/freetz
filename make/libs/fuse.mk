FUSE_VERSION:=2.6.3
FUSE_SOURCE:=fuse-$(FUSE_VERSION).tar.gz
FUSE_SITE:=http://mesh.dl.sourceforge.net/sourceforge/fuse
FUSE_DIR:=$(SOURCE_DIR)/fuse-$(FUSE_VERSION)
FUSE_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(FUSE_SOURCE):
	wget -P $(DL_DIR) $(FUSE_SITE)/$(FUSE_SOURCE)

$(FUSE_DIR)/.unpacked: $(DL_DIR)/$(FUSE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FUSE_SOURCE)
	for i in $(FUSE_MAKE_DIR)/patches/*.fuse.patch; do \
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

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
fuse fuse-precompiled:
	@echo 'External compiler used. Trying to copy libfuse from external Toolchain...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libfuse*.so* root/usr/lib/
else
fuse: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse.so
fuse-precompiled: fuse
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so* root/usr/lib/
	mkdir -p $(KERNEL_TARGET_DIR)/modules-$(KERNEL_REF)-$(AVM_VERSION)/lib/modules/2.6.13.1-ohio/kernel/fs/fuse
	cp -a $(FUSE_DIR)/kernel/fuse.ko $(KERNEL_TARGET_DIR)/modules-$(KERNEL_REF)-$(AVM_VERSION)/lib/modules/2.6.13.1-ohio/kernel/fs/fuse

endif

fuse-source: $(FUSE_DIR)/.unpacked

fuse-clean:
	-$(MAKE) -C $(FUSE_DIR) clean

fuse-uninstall:
	rm -rf root/usr/lib/libfuse*.so*

fuse-dirclean:
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfuse*.so.*
	rm -rf $(FUSE_DIR)
