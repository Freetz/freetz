# This has to be done in an extra file because gcc.mk is not included
# when download-toolchain is active
ifneq ($(strip $(DS_BUILD_TOOLCHAIN)),y)
	DEPEND:=$(TOOLCHAIN_DIR)/target/.installed
else
	DEPEND:=$(GCC_BUILD_DIR2)/.installed
endif

$(ROOT_DIR)/lib/libgcc_s.so.1: $(DEPEND) 
	-cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/lib/libgcc_s* $(ROOT_DIR)/lib/
	$(TARGET_STRIP) $(ROOT_DIR)/lib/libgcc_s.so.1