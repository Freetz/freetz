CCACHE_KERNEL_VERSION:=3.1.9
CCACHE_KERNEL_SOURCE:=ccache-$(CCACHE_KERNEL_VERSION).tar.bz2
CCACHE_KERNEL_MD5:=65f48376a91d3651d6527ca568858be8
CCACHE_KERNEL_SITE:=http://samba.org/ftp/ccache

CCACHE_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/ccache-$(CCACHE_KERNEL_VERSION)
CCACHE_KERNEL_BINARY:=ccache
CCACHE_KERNEL_TARGET_BINARY:=bin/ccache

CCACHE_CACHE_DIR=$(HOME)/.freetz-ccache

CCACHE_KERNEL_BIN_DIR:=$(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache

ccache-kernel-source: $(DL_DIR)/$(CCACHE_KERNEL_SOURCE)
$(DL_DIR)/$(CCACHE_KERNEL_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(CCACHE_KERNEL_SOURCE) $(CCACHE_KERNEL_SITE) $(CCACHE_KERNEL_MD5)

ccache-kernel-unpacked: $(CCACHE_KERNEL_DIR)/.unpacked
$(CCACHE_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(CCACHE_KERNEL_SOURCE) | $(KERNEL_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(CCACHE_KERNEL_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(CCACHE_KERNEL_SOURCE),$(KERNEL_TOOLCHAIN_DIR))
	# WARNING - this will break if the toolchain is moved.
	# Should probably patch things to use a relative path.
	$(SED) -i -e "s,getenv(\"CCACHE_PATH\"),\"$(CCACHE_KERNEL_BIN_DIR)\",g" \
		$(CCACHE_KERNEL_DIR)/execute.c
#	$(SED) -i -e "s,getenv(\"CCACHE_DIR\"),\"$(KERNEL_TOOLCHAIN_STAGING_DIR)/var/cache\",g" \
#		$(CCACHE_KERNEL_DIR)/ccache.c
	$(SED) -i 's,getenv("CCACHE_DIR"),"$(CCACHE_CACHE_DIR)",' $(CCACHE_KERNEL_DIR)/ccache.c
	mkdir -p $(CCACHE_KERNEL_DIR)/cache
	touch $@

$(CCACHE_KERNEL_DIR)/.configured: $(CCACHE_KERNEL_DIR)/.unpacked
	mkdir -p $(CCACHE_KERNEL_DIR)/
	(cd $(CCACHE_KERNEL_DIR); $(RM) config.cache; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		./configure \
		--target=$(REAL_GNU_KERNEL_NAME) \
		--host=$(GNU_HOST_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
	);
	touch $@

$(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY): $(CCACHE_KERNEL_DIR)/.configured
	$(MAKE) -C $(CCACHE_KERNEL_DIR)

$(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY): $(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY)
	mkdir -p $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin
	mkdir -p $(CCACHE_CACHE_DIR)
	cp $(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY) $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
	# Keep the actual toolchain binaries in a directory at the same level.
	# Otherwise, relative paths for include dirs break.
	mkdir -p $(CCACHE_KERNEL_BIN_DIR)
	[ -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc -a \
		! -h $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc ] && \
		mv $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc $(CCACHE_KERNEL_BIN_DIR)/ || true
	( cd $(CCACHE_KERNEL_BIN_DIR); \
		ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(REAL_GNU_TARGET_NAME)-cc \
	); \
	( cd $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin; \
		ln -fs ccache $(REAL_GNU_KERNEL_NAME)-gcc )

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
ccache-kernel: gcc-kernel $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
else
ccache-kernel: $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
endif

ccache-kernel-clean:
	if [ -f $(CCACHE_KERNEL_BIN_DIR)/$(REAL_GNU_KERNEL_NAME)-gcc ] ; then \
		$(RM) $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc; \
		mv $(CCACHE_KERNEL_BIN_DIR)/$(REAL_GNU_KERNEL_NAME)-gcc $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/; \
	fi
	$(RM) -r $(CCACHE_KERNEL_BIN_DIR)
	$(RM) $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
	-$(MAKE) -C $(CCACHE_KERNEL_DIR) clean

ccache-kernel-dirclean: ccache-kernel-clean
	$(RM) -r $(CCACHE_KERNEL_DIR)

.PHONY: ccache-kernel ccache-kernel-source ccache-kernel-unpacked ccache-kernel-clean ccache-kernel-dirclean
