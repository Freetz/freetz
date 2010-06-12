# This has to be done in an extra file because gcc.mk is not included
# when download-toolchain is active
ifneq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
	DEPEND:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-gcc
else
	DEPEND:=$(GCC_BUILD_DIR2)/.installed
endif

$(TARGET_SPECIFIC_ROOT_DIR)/lib/libgcc_s.so.1: $(DEPEND)
	mkdir -p $(dir $@)
	-cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/lib/libgcc_s* $(dir $@)
	$(TARGET_STRIP) $@
