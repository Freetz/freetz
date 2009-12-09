LIBTOOL_HOST_VERSION:=1.5.26
LIBTOOL_HOST_SOURCE:=libtool-$(LIBTOOL_HOST_VERSION).tar.gz
LIBTOOL_HOST_SOURCE_MD5:=aa9c5107f3ec9ef4200eb6556f3b3c29
LIBTOOL_HOST_SITE:=http://ftp.gnu.org/gnu/libtool
LIBTOOL_HOST_DIR:=$(TARGET_TOOLCHAIN_DIR)/libtool-$(LIBTOOL_HOST_VERSION)
LIBTOOL_HOST_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/libtool-host
LIBTOOL_HOST_SCRIPT:=$(LIBTOOL_HOST_DIR)/libtool
LIBTOOL_HOST_TARGET_SCRIPT:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libtool

GLOBAL_LIBDIR=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

# Commented out to avoid collision with make/libs/libtool.mk
#$(DL_DIR)/$(LIBTOOL_HOST_SOURCE): | $(DL_DIR)
#	$(DL_TOOL) $(DL_DIR) $(TOOLS_DOT_CONFIG) $(LIBTOOL_HOST_SOURCE) $(LIBTOOL_HOST_SITE) $(LIBTOOL_HOST_SOURCE_MD5)

$(LIBTOOL_HOST_DIR)/.unpacked: $(DL_DIR)/$(LIBTOOL_HOST_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBTOOL_HOST_SOURCE)
	touch $@


$(LIBTOOL_HOST_DIR)/.patched: $(LIBTOOL_HOST_DIR)/.unpacked
	for i in $(LIBTOOL_HOST_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(LIBTOOL_HOST_DIR) $$i; \
	done
	touch $@

$(LIBTOOL_HOST_DIR)/.configured: $(LIBTOOL_HOST_DIR)/.patched
	(cd $(LIBTOOL_HOST_DIR); rm -rf config.cache; \
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
	$(SED) -i -r -e 's,(hardcode_into_libs)=yes,\1=no,g' $(LIBTOOL_HOST_TARGET_SCRIPT)

libtool-host: $(LIBTOOL_HOST_TARGET_SCRIPT)

libtool-host-source: $(LIBTOOL_HOST_DIR)/.unpacked

libtool-host-clean:
	-$(MAKE) -C $(LIBTOOL_HOST_DIR) clean

libtool-host-dirclean:
	$(RM) -r \
		$(LIBTOOL_HOST_DIR) \
		$(LIBTOOL_HOST_TARGET_SCRIPT) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libtoolize \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/libtool.m4 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/ltdl.m4 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/libtool/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/info/libtool.info
