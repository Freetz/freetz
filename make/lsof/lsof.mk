# based on buildroot SVN
PACKAGE_LC:=lsof
PACKAGE_UC:=LSOF
$(PACKAGE_UC)_VERSION:=4.78
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=lsof_$($(PACKAGE_UC)_VERSION).dfsg.1.orig.tar.gz
$(PACKAGE_UC)_SITE:=http://ftp2.de.debian.org/debian/pool/main/l/lsof
$(PACKAGE_UC)_DIR:=$(SOURCE_DIR)/lsof-$($(PACKAGE_UC)_VERSION).dfsg.1
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/lsof
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/bin/lsof

LSOF_CFLAGS:=
ifeq ($(DS_TARGET_LFS),y)
LSOF_CFLAGS+=-U_FILE_OFFSET_BITS
endif

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)

$($(PACKAGE_UC)_DIR)/.configured: $($(PACKAGE_UC)_DIR)/.unpacked
	(cd $(LSOF_DIR); echo n | $(TARGET_CONFIGURE_OPTS) DEBUG="$(TARGET_CFLAGS) $(LSOF_CFLAGS)" LSOF_INCLUDE=$(TARGET_MAKE_PATH)/../usr/include ./Configure linux)
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LSOF_DIR) \
		CC=$(TARGET_CC) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		DEBUG="$(TARGET_CFLAGS) $(DS_LSOF_CFLAGS)"

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY) 
	$(INSTALL_BINARY_STRIP)

lsof:

lsof-precompiled: uclibc lsof $($(PACKAGE_UC)_TARGET_BINARY) 


lsof-clean:
	-$(MAKE) -C $(LSOF_DIR) clean
	-rm -f $(PACKAGES_BUILD_DIR)/$(LSOF_PKG_SOURCE)

lsof-uninstall: 
	rm -f $(LSOF_TARGET_BINARY)

$(PACKAGE_FINI)
