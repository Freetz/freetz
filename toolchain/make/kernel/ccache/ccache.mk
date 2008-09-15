CCACHE_KERNEL_VERSION:=2.4
CCACHE_KERNEL_SOURCE:=ccache-$(CCACHE_KERNEL_VERSION).tar.gz
CCACHE_KERNEL_SITE:=http://samba.org/ftp/ccache
CCACHE_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/ccache-$(CCACHE_KERNEL_VERSION)
CCACHE_KERNEL_BINARY:=ccache
CCACHE_KERNEL_TARGET_BINARY:=usr/bin/ccache

ifneq ($(strip $(DL_DIR)/$(CCACHE_KERNEL_SOURCE)), $(strip $(DL_DIR)/$(CCACHE_SOURCE)))
$(DL_DIR)/$(CCACHE_KERNEL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(CCACHE_KERNEL_SITE)/$(CCACHE_KERNEL_SOURCE)
endif

$(CCACHE_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(CCACHE_KERNEL_SOURCE) | $(KERNEL_TOOLCHAIN_DIR)
	tar -C $(KERNEL_TOOLCHAIN_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(CCACHE_KERNEL_SOURCE)
	touch $@

$(CCACHE_KERNEL_DIR)/.patched: $(CCACHE_KERNEL_DIR)/.unpacked
	# WARNING - this will break if the toolchain is moved.
	# Should probably patch things to use a relative path.
	$(SED) -i -e "s,getenv(\"CCACHE_PATH\"),\"$(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache\",g" \
		$(CCACHE_KERNEL_DIR)/execute.c
	$(SED) -i -e "s,getenv(\"CCACHE_DIR\"),\"$(KERNEL_TOOLCHAIN_STAGING_DIR)/var/cache\",g" \
		$(CCACHE_KERNEL_DIR)/ccache.c
	mkdir -p $(CCACHE_KERNEL_DIR)/cache	
	touch $@

$(CCACHE_KERNEL_DIR)/.configured: $(CCACHE_KERNEL_DIR)/.patched
	mkdir -p $(CCACHE_KERNEL_DIR)/
	( cd $(CCACHE_KERNEL_DIR); rm -f config.cache; \
		CC="$(HOSTCC)" \
		./configure \
		--target=$(REAL_GNU_KERNEL_NAME) \
		--host=$(GNU_HOST_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
	);
	touch $@

$(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY): $(CCACHE_KERNEL_DIR)/.configured
	$(MAKE) CC="$(HOSTCC)" -C $(CCACHE_KERNEL_DIR)

$(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY): $(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY)
	mkdir -p $(KERNEL_TOOLCHAIN_STAGING_DIR)/usr/bin
	mkdir -p $(KERNEL_TOOLCHAIN_STAGING_DIR)/var/cache
	cp $(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY) $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
	# Keep the actual toolchain binaries in a directory at the same level.
	# Otherwise, relative paths for include dirs break.
	mkdir -p $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache
	(cd $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache; \
		ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(GNU_TARGET_NAME)-gcc; \
		ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(GNU_TARGET_NAME)-cc; \
		ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(REAL_GNU_KERNEL_NAME)-cc);
	[ -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc ] && \
		mv $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache/
		( cd $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache; \
			ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(GNU_TARGET_NAME)-gcc; \
			ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(GNU_TARGET_NAME)-cc; \
			ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(REAL_GNU_TARGET_NAME)-cc \
		); \
		( cd $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin; \
			ln -fs ../usr/bin/ccache $(GNU_TARGET_NAME)-cc; \
			ln -fs ../usr/bin/ccache $(GNU_TARGET_NAME)-gcc; \
			ln -fs ../usr/bin/ccache $(REAL_GNU_KERNEL_NAME)-cc; \
			ln -fs ../usr/bin/ccache $(REAL_GNU_KERNEL_NAME)-gcc);

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
ccache-kernel: gcc-kernel $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
else
ccache-kernel: $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
endif

ccache-kernel-clean:
	rm -rf  $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-cc
	rm -rf  $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-gcc
	rm -rf  $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-cc
	rm -rf  $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc
	if [ -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_KERNEL_NAME)-gcc ] ; then \
		mv $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_KERNEL_NAME)-gcc $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/; \
		(cd $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin; \
		    ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(REAL_GNU_KERNEL_NAME)-cc; \
		    ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(GNU_TARGET_NAME)-cc; \
		    ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(GNU_TARGET_NAME)-gcc); \
	fi;
	rm -rf  $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache/*
	-$(MAKE) -C $(CCACHE_KERNEL_DIR) clean

ccache-kernel-dirclean: ccache-kernel-clean
	rm -rf $(CCACHE_KERNEL_DIR)

.PHONY: ccache-kernel
