# This has to be done in an extra file because gcc.mk is not included
# when download-toolchain is active
ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
	LIBGCC_PREREQ=$(GCC_BUILD_DIR2)/.installed
else
	LIBGCC_PREREQ=$(TARGET_CROSS_COMPILER)
endif

$(TARGET_SPECIFIC_ROOT_DIR)/lib/libgcc_s.so.1: $(LIBGCC_PREREQ)
	mkdir -p $(dir $@)
	-cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/lib/libgcc_s.so* $(dir $@)
	$(TARGET_STRIP) $@
