PACKAGE_LC:=ntfs
PACKAGE_UC:=NTFS
NTFS_VERSION:=1.1004
NTFS_LIB_VERSION:=13.0.0
NTFS_SOURCE:=ntfs-3g-$(NTFS_VERSION).tgz
NTFS_SITE:=http://www.ntfs-3g.org/
NTFS_MAKE_DIR:=$(MAKE_DIR)/ntfs
NTFS_DIR:=$(SOURCE_DIR)/ntfs-3g-$(NTFS_VERSION)
NTFS_BINARY:=$(NTFS_DIR)/src/ntfs-3g
NTFS_TARGET_DIR:=$(PACKAGES_DIR)/ntfs-$(NTFS_VERSION)
NTFS_TARGET_BINARY:=$(NTFS_TARGET_DIR)/root/usr/bin/ntfs-3g
NTFS_STARTLEVEL=30

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)

$(NTFS_DIR)/.configured: $(NTFS_DIR)/.unpacked
	(cd $(NTFS_DIR); rm -f config.cache; \
		touch configure.in ; \
		touch aclocal.m4 ; \
		touch Makefile.in ; \
		touch include/config.h.in ; \
		touch configure ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		FUSE_MODULE_CFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include/fuse" \
		FUSE_MODULE_LIBS="-pthread -lfuse -ldl" \
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
			--disable-shared \
			--enable-static \
			--disable-rpath \
			--enable-kernel-module \
			--enable-lib \
			--enable-util \
			--disable-example \
			--disable-auto-modprobe \
			--with-kernel="$(shell pwd)/../$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/" \
			--disable-mtab \
	);
	touch $@

$(NTFS_BINARY) $(NTFS_LIB_BINARY): $(NTFS_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		-C $(NTFS_DIR) all

$(NTFS_TARGET_BINARY): $(NTFS_BINARY)
	mkdir -p $(dir $(NTFS_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.ntfs-$(NTFS_UTILS_VERSION):
	mkdir -p $(NTFS_TARGET_DIR)/root
	cp -a $(NTFS_MAKE_DIR)/files/* $(NTFS_TARGET_DIR)/root

ntfs: uclibc fuse $(PACKAGES_DIR)/.ntfs-$(NTFS_UTILS_VERSION) \
	$(NTFS_TARGET_BINARY)

ntfs-precompiled: fuse-precompiled ntfs $(NTFS_TARGET_BINARY)

ntfs-source: $(NTFS_DIR)/.unpacked

ntfs-clean:
	-$(MAKE) -C $(NTFS_DIR) clean

ntfs-dirclean:
	rm -rf $(NTFS_DIR)

ntfs-uninstall:
	rm -f $(NTFS_TARGET_BINARY)

$(PACKAGE_LIST)
