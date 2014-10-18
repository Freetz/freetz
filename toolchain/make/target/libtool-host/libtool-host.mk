LIBTOOL_HOST_VERSION:=1.5.26
LIBTOOL_HOST_SOURCE:=libtool-$(LIBTOOL_HOST_VERSION).tar.gz
LIBTOOL_HOST_SOURCE_MD5:=aa9c5107f3ec9ef4200eb6556f3b3c29
LIBTOOL_HOST_SITE:=@GNU/libtool
LIBTOOL_HOST_DIR:=$(TARGET_TOOLCHAIN_DIR)/libtool-$(LIBTOOL_HOST_VERSION)
LIBTOOL_HOST_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/libtool-host
LIBTOOL_HOST_SCRIPT:=$(LIBTOOL_HOST_DIR)/libtool
LIBTOOL_HOST_TARGET_SCRIPT:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libtool

GLOBAL_LIBDIR=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

libtool-host-source: $(DL_DIR)/$(LIBTOOL_HOST_SOURCE)
ifneq ($(strip $(DL_DIR)/$(LIBTOOL_HOST_SOURCE)), $(strip $(DL_DIR)/$(LIBTOOL_SOURCE)))
$(DL_DIR)/$(LIBTOOL_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LIBTOOL_HOST_SOURCE) $(LIBTOOL_HOST_SITE) $(LIBTOOL_HOST_SOURCE_MD5)
endif

libtool-host-unpacked: $(LIBTOOL_HOST_DIR)/.unpacked
$(LIBTOOL_HOST_DIR)/.unpacked: $(DL_DIR)/$(LIBTOOL_HOST_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(LIBTOOL_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LIBTOOL_HOST_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	for i in $(LIBTOOL_HOST_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(LIBTOOL_HOST_DIR) $$i; \
	done
# touch some patched files to ensure no file except for ltmain.sh gets regenerated
	for i in $$(find $(LIBTOOL_HOST_DIR) -type f \( \( -name "*.m4" -o -name "*.am" \) -a ! -name "aclocal.m4" \)); do \
		touch -t 200001010000.00 $$i; \
	done; \
	touch $@

libtool-host-configured: $(LIBTOOL_HOST_DIR)/.configured
$(LIBTOOL_HOST_DIR)/.configured: $(LIBTOOL_HOST_DIR)/.unpacked | $(TARGET_CXX_CROSS_COMPILER_SYMLINK_TIMESTAMP)
	(cd $(LIBTOOL_HOST_DIR); rm -rf config.cache; \
		CC=$(TARGET_CC) \
		CXX=$(TARGET_CXX) \
		CFLAGS="$(TARGET_CFLAGS)" \
		PATH=$(TARGET_PATH) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--prefix=/usr \
		--disable-ltdl-install \
		--enable-shared \
		--enable-static \
		$(DISABLE_NLS) \
	);
	touch $@

$(LIBTOOL_HOST_SCRIPT): $(LIBTOOL_HOST_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBTOOL_HOST_DIR) \
		GLOBAL_LIBDIR=$(GLOBAL_LIBDIR) \
		all
	touch -c $@

$(LIBTOOL_HOST_TARGET_SCRIPT): $(LIBTOOL_HOST_SCRIPT)
	$(MAKE) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		MAKEINFO=true \
		-C $(LIBTOOL_HOST_DIR) \
		install
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))

libtool-host: $(LIBTOOL_HOST_TARGET_SCRIPT) | $(STDCXXLIB)

libtool-host-clean:
	-$(MAKE) -C $(LIBTOOL_HOST_DIR) clean

libtool-host-dirclean:
	$(RM) -r \
		$(LIBTOOL_HOST_DIR) \
		$(LIBTOOL_HOST_TARGET_SCRIPT) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libtoolize \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/libtool.m4 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/ltdl.m4 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/libtool/
