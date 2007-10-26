# based on buildroot SVN
PACKAGE_LC:=lsof
PACKAGE_UC:=LSOF
LSOF_VERSION:=4.78
LSOF_SOURCE:=lsof_$(LSOF_VERSION).dfsg.1.orig.tar.gz
LSOF_SITE:=http://ftp2.de.debian.org/debian/pool/main/l/lsof
LSOF_MAKE_DIR:=$(MAKE_DIR)/lsof
LSOF_DIR:=$(SOURCE_DIR)/lsof-$(LSOF_VERSION).dfsg.1
LSOF_BINARY:=$(LSOF_DIR)/lsof
LSOF_TARGET_DIR:=$(PACKAGES_DIR)/lsof-$(LSOF_VERSION)
LSOF_TARGET_BINARY:=$(LSOF_TARGET_DIR)/root/usr/bin/lsof
LSOF_STARTLEVEL=40

LSOF_CFLAGS:=
ifeq ($(DS_TARGET_LFS),y)
LSOF_CFLAGS+=-U_FILE_OFFSET_BITS
endif

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)

$(LSOF_DIR)/.configured: $(LSOF_DIR)/.unpacked
	(cd $(LSOF_DIR); echo n | $(TARGET_CONFIGURE_OPTS) DEBUG="$(TARGET_CFLAGS) $(LSOF_CFLAGS)" LSOF_INCLUDE=$(TARGET_MAKE_PATH)/../usr/include ./Configure linux)
	touch $@

$(LSOF_BINARY): $(LSOF_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LSOF_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CC=$(TARGET_CC) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		DEBUG="$(TARGET_CFLAGS) $(DS_LSOF_CFLAGS)"

$(LSOF_TARGET_BINARY): $(LSOF_BINARY) 
	mkdir -p $(dir $(LSOF_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

lsof:

lsof-precompiled: uclibc lsof $(LSOF_TARGET_BINARY) 

lsof-source: $(LSOF_DIR)/.unpacked

lsof-clean:
	-$(MAKE) -C $(LSOF_DIR) clean
	-rm -f $(PACKAGES_BUILD_DIR)/$(LSOF_PKG_SOURCE)

lsof-dirclean:
	rm -rf $(LSOF_DIR)
	rm -rf $(PACKAGES_DIR)/lsof-$(LSOF_VERSION)

lsof-uninstall: 
	rm -f $(LSOF_TARGET_BINARY)

$(PACKAGE_LIST)
