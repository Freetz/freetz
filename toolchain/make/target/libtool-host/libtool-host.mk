LIBTOOL_HOST_VERSION:=1.5.26
LIBTOOL_HOST_SOURCE:=libtool-$(LIBTOOL_HOST_VERSION).tar.gz
LIBTOOL_HOST_SOURCE_MD5:=aa9c5107f3ec9ef4200eb6556f3b3c29
LIBTOOL_HOST_SITE:=@GNU/libtool
LIBTOOL_HOST_DIR:=$(TARGET_TOOLCHAIN_DIR)/libtool-$(LIBTOOL_HOST_VERSION)
LIBTOOL_HOST_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/libtool-host
LIBTOOL_HOST_SCRIPT:=$(LIBTOOL_HOST_DIR)/libtool
LIBTOOL_HOST_TARGET_SCRIPT:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libtool

GLOBAL_LIBDIR=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

LIBTOOL_HOST_ECHO_TYPE:=TTC
LIBTOOL_HOST_ECHO_MAKE:=libtool


libtool-host-source: $(DL_DIR)/$(LIBTOOL_HOST_SOURCE)
ifneq ($(strip $(DL_DIR)/$(LIBTOOL_HOST_SOURCE)), $(strip $(DL_DIR)/$(LIBTOOL_SOURCE)))
$(DL_DIR)/$(LIBTOOL_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(LIBTOOL_HOST_SOURCE) $(LIBTOOL_HOST_SITE) $(LIBTOOL_HOST_SOURCE_MD5)
endif

libtool-host-unpacked: $(LIBTOOL_HOST_DIR)/.unpacked
$(LIBTOOL_HOST_DIR)/.unpacked: $(DL_DIR)/$(LIBTOOL_HOST_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,unpacking,$(LIBTOOL_HOST_ECHO_TYPE),$(LIBTOOL_HOST_ECHO_MAKE))
	$(RM) -r $(LIBTOOL_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LIBTOOL_HOST_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(LIBTOOL_HOST_MAKE_DIR)/patches,$(LIBTOOL_HOST_DIR))
# touch some patched files to ensure no file except for ltmain.sh gets regenerated
	for i in $$(find $(LIBTOOL_HOST_DIR) -type f \( \( -name "*.m4" -o -name "*.am" \) -a ! -name "aclocal.m4" \)); do \
		touch -t 200001010000.00 $$i; \
	done; \
	touch $@

libtool-host-configured: $(LIBTOOL_HOST_DIR)/.configured
$(LIBTOOL_HOST_DIR)/.configured: $(LIBTOOL_HOST_DIR)/.unpacked | $(TARGET_CXX_CROSS_COMPILER_SYMLINK_TIMESTAMP)
	@$(call _ECHO,configuring,$(LIBTOOL_HOST_ECHO_TYPE),$(LIBTOOL_HOST_ECHO_MAKE))
	(cd $(LIBTOOL_HOST_DIR); $(RM) config.cache; \
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
		$(SILENT) \
	);
	touch $@

$(LIBTOOL_HOST_SCRIPT): $(LIBTOOL_HOST_DIR)/.configured
	@$(call _ECHO,building,$(LIBTOOL_HOST_ECHO_TYPE),$(LIBTOOL_HOST_ECHO_MAKE))
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBTOOL_HOST_DIR) \
		GLOBAL_LIBDIR=$(GLOBAL_LIBDIR) \
		all $(SILENT)
	touch -c $@

$(LIBTOOL_HOST_TARGET_SCRIPT): $(LIBTOOL_HOST_SCRIPT)
	@$(call _ECHO,installing,$(LIBTOOL_HOST_ECHO_TYPE),$(LIBTOOL_HOST_ECHO_MAKE))
	$(MAKE) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		MAKEINFO=true \
		-C $(LIBTOOL_HOST_DIR) \
		install $(SILENT)
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

libtool-host-distclean: libtool-host-dirclean


.PHONY: libtool-host libtool-host-source libtool-host-unpacked
.PHONY: libtool-host-clean libtool-host-dirclean libtool-host-distclean

