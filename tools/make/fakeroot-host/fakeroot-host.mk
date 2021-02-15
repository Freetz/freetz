FAKEROOT_HOST_VERSION:=1.23
FAKEROOT_HOST_SOURCE:=fakeroot_$(FAKEROOT_HOST_VERSION).orig.tar.xz
FAKEROOT_HOST_SOURCE_MD5:=b82c5e99b6365a838e73d05718083f6a
FAKEROOT_HOST_SITE:=http://ftp.debian.org/debian/pool/main/f/fakeroot

FAKEROOT_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/fakeroot-host
FAKEROOT_HOST_DIR:=$(TOOLS_SOURCE_DIR)/fakeroot-$(FAKEROOT_HOST_VERSION)
FAKEROOT_HOST_MAINARCH_DIR:=$(FAKEROOT_HOST_DIR)/build/arch
FAKEROOT_HOST_BIARCH_DIR:=$(FAKEROOT_HOST_DIR)/build/biarch

FAKEROOT_HOST_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
FAKEROOT_HOST_MAINARCH_LD_PRELOAD_PATH:=$(FAKEROOT_HOST_DESTDIR)/lib
FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH:=$(FAKEROOT_HOST_DESTDIR)/lib32
FAKEROOT_HOST_TARGET_SCRIPT:=$(FAKEROOT_HOST_DESTDIR)/bin/fakeroot
FAKEROOT_HOST_TARGET_BIARCH_LIB:=$(FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH)/libfakeroot-0.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit fakeroot support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# The correct condition here would be:
# (using 32-bit toolchain) AND (any of the STRIP-options is selected) AND (host is 64-bit)
BIARCH_BUILD_SYSTEM:=$(and \
	$(or $(FREETZ_DOWNLOAD_TOOLCHAIN),$(FREETZ_TOOLCHAIN_32BIT)), \
	$(filter-out 32,$(HOST_BITNESS)))


fakeroot-host-source: $(DL_DIR)/$(FAKEROOT_HOST_SOURCE)
$(DL_DIR)/$(FAKEROOT_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FAKEROOT_HOST_SOURCE) $(FAKEROOT_HOST_SITE) $(FAKEROOT_HOST_SOURCE_MD5)

fakeroot-host-unpacked: $(FAKEROOT_HOST_DIR)/.unpacked
$(FAKEROOT_HOST_DIR)/.unpacked: $(DL_DIR)/$(FAKEROOT_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FAKEROOT_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(FAKEROOT_HOST_MAKE_DIR)/patches,$(FAKEROOT_HOST_DIR))
	touch $@

$(FAKEROOT_HOST_MAINARCH_DIR)/.configured: $(FAKEROOT_HOST_DIR)/.unpacked
	(mkdir -p $(FAKEROOT_HOST_MAINARCH_DIR); cd $(FAKEROOT_HOST_MAINARCH_DIR); $(RM) config.cache; \
		CFLAGS="-O3 -Wall" \
		CC="$(TOOLS_CC)" \
		../../configure \
		--prefix=$(FAKEROOT_HOST_DESTDIR) \
		--enable-shared \
		$(if $(findstring Microsoft,$(shell uname -r)),--with-ipc=tcp,) \
		$(DISABLE_NLS) \
	);
	touch $@

$(FAKEROOT_HOST_TARGET_SCRIPT): $(FAKEROOT_HOST_MAINARCH_DIR)/.configured
	$(MAKE) -C $(FAKEROOT_HOST_MAINARCH_DIR) install
	$(SED) -i -e 's,^PATHS=.*,PATHS=$(FAKEROOT_HOST_MAINARCH_LD_PRELOAD_PATH):$(FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH),g' $(FAKEROOT_HOST_TARGET_SCRIPT)

$(FAKEROOT_HOST_BIARCH_DIR)/.configured: $(FAKEROOT_HOST_DIR)/.unpacked
	(mkdir -p $(FAKEROOT_HOST_BIARCH_DIR); cd $(FAKEROOT_HOST_BIARCH_DIR); $(RM) config.cache; \
		CFLAGS="$(HOST_CFLAGS_FORCE_32BIT_CODE) -O3 -Wall" \
		CC="$(TOOLS_CC)" \
		../../configure \
		--prefix=$(FAKEROOT_HOST_DESTDIR) \
		--enable-shared \
		$(if $(findstring Microsoft,$(shell uname -r)),--with-ipc=tcp,) \
		$(if $(findstring Microsoft,$(shell uname -r)),--host=$(shell uname -m),) \
		$(DISABLE_NLS) \
		$(QUIET) \
	);
	touch $@

$(FAKEROOT_HOST_TARGET_BIARCH_LIB): $(FAKEROOT_HOST_BIARCH_DIR)/.configured
	$(MAKE) -C $(FAKEROOT_HOST_BIARCH_DIR) libdir="$(FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH)" install-libLTLIBRARIES

fakeroot-host: $(FAKEROOT_HOST_TARGET_SCRIPT) $(if $(BIARCH_BUILD_SYSTEM),$(FAKEROOT_HOST_TARGET_BIARCH_LIB))


fakeroot-host-clean:
	-$(MAKE) -C $(FAKEROOT_HOST_MAINARCH_DIR) clean
	-$(MAKE) -C $(FAKEROOT_HOST_BIARCH_DIR) clean

fakeroot-host-dirclean:
	$(RM) -r $(FAKEROOT_HOST_DIR)

fakeroot-host-distclean: fakeroot-host-dirclean
	$(RM) -r $(FAKEROOT_HOST_TARGET_SCRIPT) $(FAKEROOT_HOST_DESTDIR)/bin/faked $(FAKEROOT_HOST_DESTDIR)/lib*/libfakeroot*

