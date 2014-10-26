CCACHE_VERSION:=3.1.9
CCACHE_SOURCE:=ccache-$(CCACHE_VERSION).tar.bz2
CCACHE_MD5:=65f48376a91d3651d6527ca568858be8
CCACHE_SITE:=http://samba.org/ftp/ccache

CCACHE_DIR:=$(TARGET_TOOLCHAIN_DIR)/ccache-$(CCACHE_VERSION)
CCACHE_BINARY:=ccache
CCACHE_TARGET_BINARY:=usr/bin/ccache

CCACHE_BIN_DIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache

CCACHE_CACHE_DIR=$(HOME)/.freetz-ccache

ccache-source: $(DL_DIR)/$(CCACHE_SOURCE)
ifneq ($(strip $(DL_DIR)/$(CCACHE_SOURCE)), $(strip $(DL_DIR)/$(CCACHE_KERNEL_SOURCE)))
$(DL_DIR)/$(CCACHE_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(CCACHE_SOURCE) $(CCACHE_SITE) $(CCACHE_MD5)
endif

ccache-unpacked: $(CCACHE_DIR)/.unpacked
$(CCACHE_DIR)/.unpacked: $(DL_DIR)/$(CCACHE_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -f $(CCACHE_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(CCACHE_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	# WARNING - this will break if the toolchain is moved.
	# Should probably patch things to use a relative path.
	$(SED) -i -e "s,getenv(\"CCACHE_PATH\"),\"$(CCACHE_BIN_DIR)\",g" \
		$(CCACHE_DIR)/execute.c
#	$(SED) -i -e "s,getenv(\"CCACHE_DIR\"),\"$(TARGET_TOOLCHAIN_STAGING_DIR)/var/cache\",g" \
#		$(CCACHE_DIR)/ccache.c
	$(SED) -i 's,getenv("CCACHE_DIR"),"$(CCACHE_CACHE_DIR)",' $(CCACHE_DIR)/ccache.c
	mkdir -p $(CCACHE_DIR)/cache
	touch $@

$(CCACHE_DIR)/.configured: $(CCACHE_DIR)/.unpacked
	(cd $(CCACHE_DIR); $(RM) config.cache; \
		CC=$(TOOLCHAIN_HOSTCC) \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		./configure \
		--target=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		$(QUIET) \
	);
	touch $@

$(CCACHE_DIR)/$(CCACHE_BINARY): $(CCACHE_DIR)/.configured
	$(MAKE) -C $(CCACHE_DIR)

$(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY): $(CCACHE_DIR)/$(CCACHE_BINARY)
	mkdir -p $(CCACHE_CACHE_DIR)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin
	cp $(CCACHE_DIR)/$(CCACHE_BINARY) $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
	# Keep the actual toolchain binaries in a directory at the same level.
	# Otherwise, relative paths for include dirs break.
	mkdir -p $(CCACHE_BIN_DIR)
	for i in gcc g++; do \
		[ -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i -a \
			! -h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i ] && \
			mv $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i \
					$(CCACHE_BIN_DIR)/ || true; \
	done
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; \
		ln -fs ccache $(REAL_GNU_TARGET_NAME)-gcc; \
		ln -fs ccache $(REAL_GNU_TARGET_NAME)-g++; \
	)
	(cd $(CCACHE_BIN_DIR); \
		ln -fs $(REAL_GNU_TARGET_NAME)-g++ $(REAL_GNU_TARGET_NAME)-c++; \
		ln -fs $(REAL_GNU_TARGET_NAME)-gcc $(REAL_GNU_TARGET_NAME)-cc; \
		for i in gcc g++ cc c++; do \
			ln -fs $(REAL_GNU_TARGET_NAME)-$$i $(GNU_TARGET_NAME)-$$i; \
		done; \
	)

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
ccache: gcc $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
else
ccache: $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
endif

ccache-clean:
	for i in gcc g++; do \
		if [ -f $(CCACHE_BIN_DIR)/$(REAL_GNU_TARGET_NAME)-$$i ] ; then \
			rm -rf  $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i; \
			mv $(CCACHE_BIN_DIR)/$(REAL_GNU_TARGET_NAME)-$$i \
				$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/; \
		fi; \
	done
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache
	-$(MAKE) -C $(CCACHE_DIR) clean

ccache-dirclean: ccache-clean
	$(RM) -r $(CCACHE_DIR)

.PHONY: ccache ccache-source ccache-unpacked ccache-clean ccache-dirclean
