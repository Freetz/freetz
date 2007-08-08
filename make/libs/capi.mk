CAPI_VERSION:=2.0
CAPI_LIB_VERSION:=3.0.4
CAPI_SOURCE:=libcapi-$(CAPI_VERSION).tar.bz2
CAPI_SITE:=http://dsmod.magenbrot.net
CAPI_MAKE_DIR:=$(MAKE_DIR)/libs
CAPI_DIR:=$(SOURCE_DIR)/libcapi-$(CAPI_VERSION)
CAPI_BINARY:=$(CAPI_DIR)/libcapi20.so.$(CAPI_LIB_VERSION)
CAPI_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libcapi20.so.$(CAPI_LIB_VERSION)
CAPI_TARGET_DIR:=root/lib
CAPI_TARGET_BINARY:=$(CAPI_TARGET_DIR)/libcapi20.so.$(CAPI_LIB_VERSION)

$(DL_DIR)/$(CAPI_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(CAPI_SITE)/$(CAPI_SOURCE)

$(CAPI_DIR)/.unpacked: $(DL_DIR)/$(CAPI_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(CAPI_SOURCE)
#	for i in $(CAPI_MAKE_DIR)/patches/*.capi.patch; do \
#		$(PATCH_TOOL) $(CAPI_DIR) $$i; \
#	done
	touch $@

$(CAPI_BINARY): $(CAPI_DIR)/.unpacked
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CAPI20_VERS="$CAPI_VERSION)" \
	$(MAKE) -C $(CAPI_DIR) all

$(CAPI_STAGING_BINARY): $(CAPI_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(CAPI_DIR) \
		FILESYSTEM="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(CAPI_TARGET_BINARY): $(CAPI_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcapi*.so* $(CAPI_TARGET_DIR)
	$(TARGET_STRIP) $@

capi: $(CAPI_STAGING_BINARY)

capi-precompiled: uclibc capi $(CAPI_TARGET_BINARY)

capi-source: $(CAPI_DIR)/.unpacked

capi-clean:
	-$(MAKE) -C $(CAPI_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcapi20.* \
			$(STAGING_DIR)/include/capi20.h \
			$(STAGING_DIR)/include/capiutils.h \
			$(STAGING_DIR)/include/capicmd.h

capi-uninstall:
	rm -f $(CAPI_TARGET_DIR)/libcapi*.so*

capi-dirclean:
	rm -rf $(CAPI_DIR)
