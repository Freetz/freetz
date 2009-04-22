CCACHE_VERSION:=2.4
CCACHE_SOURCE:=ccache-$(CCACHE_VERSION).tar.gz
CCACHE_MD5:=73c1ed1e767c1752dd0f548ec1e66ce7
CCACHE_SITE:=http://samba.org/ftp/ccache
CCACHE_DIR:=$(TARGET_TOOLCHAIN_DIR)/ccache-$(CCACHE_VERSION)
CCACHE_BINARY:=ccache
CCACHE_TARGET_BINARY:=usr/bin/ccache

ifneq ($(strip $(DL_DIR)/$(CCACHE_SOURCE)), $(strip $(DL_DIR)/$(CCACHE_SOURCE)))
$(DL_DIR)/$(CCACHE_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(CCACHE_SOURCE) $(CCACHE_SITE) $(CCACHE_MD5)
endif

$(CCACHE_DIR)/.unpacked: $(DL_DIR)/$(CCACHE_SOURCE) | $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(CCACHE_SOURCE)
	touch $@

$(CCACHE_DIR)/.patched: $(CCACHE_DIR)/.unpacked
	# WARNING - this will break if the toolchain is moved.
	# Should probably patch things to use a relative path.
	$(SED) -i -e "s,getenv(\"CCACHE_PATH\"),\"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache\",g" \
		$(CCACHE_DIR)/execute.c
	$(SED) -i -e "s,getenv(\"CCACHE_DIR\"),\"$(TARGET_TOOLCHAIN_STAGING_DIR)/var/cache\",g" \
		$(CCACHE_DIR)/ccache.c
	mkdir -p $(CCACHE_DIR)/cache
	touch $@

$(CCACHE_DIR)/.configured: $(CCACHE_DIR)/.patched
	mkdir -p $(CCACHE_DIR)/
	( cd $(CCACHE_DIR); rm -f config.cache; \
		CC=$(HOSTCC) \
		./configure \
		--target=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		$(QUIET) \
	);
	touch $@

$(CCACHE_DIR)/$(CCACHE_BINARY): $(CCACHE_DIR)/.configured
	$(MAKE) CC=$(HOSTCC) -C $(CCACHE_DIR)

$(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY): $(CCACHE_DIR)/$(CCACHE_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/var/cache
	cp $(CCACHE_DIR)/$(CCACHE_BINARY) $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
	# Keep the actual toolchain binaries in a directory at the same level.
	# Otherwise, relative paths for include dirs break.
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache; \
		ln -fs $(REAL_GNU_TARGET_NAME)-gcc $(GNU_TARGET_NAME)-gcc; \
		ln -fs $(REAL_GNU_TARGET_NAME)-gcc $(GNU_TARGET_NAME)-cc; \
		ln -fs $(REAL_GNU_TARGET_NAME)-gcc $(REAL_GNU_TARGET_NAME)-cc; \
	)
	[ -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-gcc ] && \
		mv $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-gcc \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache/
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; \
			ln -fs ccache $(GNU_TARGET_NAME)-cc; \
			ln -fs ccache $(GNU_TARGET_NAME)-gcc; \
			ln -fs ccache $(REAL_GNU_TARGET_NAME)-cc; \
			ln -fs ccache $(REAL_GNU_TARGET_NAME)-gcc; \
	)
ifeq ($(FREETZ_TARGET_GXX),y)
	[ -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-c++ ] && \
		mv $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-c++ \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache/
	[ -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-g++ ] && \
		mv $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-g++ \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache/
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; \
		ln -fs ccache $(GNU_TARGET_NAME)-c++; \
		ln -fs ccache $(GNU_TARGET_NAME)-g++;\
		ln -fs ccache $(REAL_GNU_TARGET_NAME)-c++; \
		ln -fs ccache $(REAL_GNU_TARGET_NAME)-g++; \
	)
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache; \
		ln -fs $(REAL_GNU_TARGET_NAME)-c++ $(GNU_TARGET_NAME)-c++; \
		ln -fs $(REAL_GNU_TARGET_NAME)-g++ $(GNU_TARGET_NAME)-g++; \
	)
endif

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
ccache: gcc $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
else
ccache: $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
endif

ccache-clean:
	rm -rf  $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(GNU_TARGET_NAME)-cc
	rm -rf  $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(GNU_TARGET_NAME)-gcc
	rm -rf  $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-cc
	rm -rf  $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-gcc
	if [ -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache/$(REAL_GNU_TARGET_NAME)-gcc ] ; then \
		mv $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache/$(REAL_GNU_TARGET_NAME)-gcc \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/; \
		(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; \
		    ln -fs $(REAL_GNU_TARGET_NAME)-gcc $(REAL_GNU_TARGET_NAME)-cc; \
		    ln -fs $(REAL_GNU_TARGET_NAME)-gcc $(GNU_TARGET_NAME)-cc; \
		    ln -fs $(REAL_GNU_TARGET_NAME)-gcc $(GNU_TARGET_NAME)-gcc; \
		); \
	fi
	if [ -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_TARGET_NAME)-c++ ] ; then \
		rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-c++; \
		mv $(TARGET_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_TARGET_NAME)-c++ \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/; \
	fi;
	if [ -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache/$(REAL_GNU_TARGET_NAME)-g++ ] ; then \
		rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-g++; \
		mv $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache/$(REAL_GNU_TARGET_NAME)-g++ \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/; \
	fi;
	rm -rf  $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache/*
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; \
		ln -fs $(REAL_GNU_TARGET_NAME)-g++ $(GNU_TARGET_NAME)-c++; \
		ln -fs $(REAL_GNU_TARGET_NAME)-g++ $(GNU_TARGET_NAME)-g++; \
		ln -fs $(REAL_GNU_TARGET_NAME)-g++ $(REAL_GNU_TARGET_NAME)-c++; \
	)
	-$(MAKE) -C $(CCACHE_DIR) clean

ccache-dirclean: ccache-clean
	rm -rf $(CCACHE_DIR)

.PHONY: ccache
