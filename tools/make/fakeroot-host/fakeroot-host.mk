$(call TOOL_INIT, 1.29)
$(TOOL)_SOURCE:=fakeroot_$($(TOOL)_VERSION).orig.tar.gz
$(TOOL)_SOURCE_SHA256:=8fbbafb780c9173e3ace4a04afbc1d900f337f3216883939f5c7db3431be7c20
$(TOOL)_SITE:=https://ftp.debian.org/debian/pool/main/f/fakeroot
### WEBSITE:=https://wiki.debian.org/FakeRoot
### MANPAGE:=https://man.archlinux.org/man/fakeroot.1.en
### TRACKER:=https://bugs.debian.org/cgi-bin/pkgreport.cgi?pkg=fakeroot;dist=unstable
### CHANGES:=https://launchpad.net/debian/+source/fakeroot/+changelog
### CVSREPO:=https://github.com/openwrt/openwrt/tree/master/tools/fakeroot/patches

$(TOOL)_MAINARCH_DIR:=$($(TOOL)_DIR)/build/arch
$(TOOL)_BIARCH_DIR:=$($(TOOL)_DIR)/build/biarch

$(TOOL)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
$(TOOL)_MAINARCH_LD_PRELOAD_PATH:=$($(TOOL)_DESTDIR)/lib
$(TOOL)_BIARCH_LD_PRELOAD_PATH:=$($(TOOL)_DESTDIR)/lib32
$(TOOL)_TARGET_SCRIPT:=$($(TOOL)_DESTDIR)/bin/fakeroot
$(TOOL)_TARGET_BIARCH_LIB:=$($(TOOL)_BIARCH_LD_PRELOAD_PATH)/libfakeroot-0.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit fakeroot support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# The correct condition here would be:
# (using 32-bit [tools/toolchains] [own/dl]) AND (any of the STRIP-options is selected) AND (host is 64-bit)
BIARCH_BUILD_SYSTEM:=$(filter-out 32,$(HOST_BITNESS))


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FAKEROOT_HOST_SOURCE) $(FAKEROOT_HOST_SITE) $(FAKEROOT_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FAKEROOT_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(FAKEROOT_HOST_MAKE_DIR)/patches,$(FAKEROOT_HOST_DIR))
	touch $@

$($(TOOL)_MAINARCH_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(mkdir -p $(FAKEROOT_HOST_MAINARCH_DIR); cd $(FAKEROOT_HOST_MAINARCH_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		../../configure \
		--prefix=$(FAKEROOT_HOST_DESTDIR) \
		--enable-shared \
		$(if $(findstring Microsoft,$(shell uname -r)),--with-ipc=tcp,--with-ipc=sysv) \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@
$($(TOOL)_TARGET_SCRIPT): $($(TOOL)_MAINARCH_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(FAKEROOT_HOST_MAINARCH_DIR) install
	$(SED) -i 's,^FAKEROOT_PREFIX=.*,FAKEROOT_PREFIX="$$(readlink -f $$0 | sed "s!/bin/fakeroot\\$$!!")",'  $(FAKEROOT_HOST_TARGET_SCRIPT)
	$(SED) -i 's,^FAKEROOT_BINDIR=.*,FAKEROOT_BINDIR=$${FAKEROOT_PREFIX}/bin,'                              $(FAKEROOT_HOST_TARGET_SCRIPT)
	$(SED) -i 's,^PATHS=.*,PATHS=$${FAKEROOT_PREFIX}/lib:$${FAKEROOT_PREFIX}/lib32,'                        $(FAKEROOT_HOST_TARGET_SCRIPT)

$($(TOOL)_BIARCH_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(mkdir -p $(FAKEROOT_HOST_BIARCH_DIR); cd $(FAKEROOT_HOST_BIARCH_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) $(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		../../configure \
		--prefix=$(FAKEROOT_HOST_DESTDIR) \
		--enable-shared \
		$(if $(findstring Microsoft,$(shell uname -r)),--with-ipc=tcp,--with-ipc=sysv) \
		$(if $(findstring Microsoft,$(shell uname -r)),--host=$(shell uname -m),) \
		$(DISABLE_NLS) \
		$(SILENT) \
	);
	touch $@
$($(TOOL)_TARGET_BIARCH_LIB): $($(TOOL)_BIARCH_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(FAKEROOT_HOST_BIARCH_DIR) libdir="$(FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH)" install-libLTLIBRARIES
	touch $@

$(tool)-precompiled: $($(TOOL)_TARGET_SCRIPT) $(if $(BIARCH_BUILD_SYSTEM),$($(TOOL)_TARGET_BIARCH_LIB))


$(tool)-clean:
	-$(MAKE) -C $(FAKEROOT_HOST_MAINARCH_DIR) clean
	-$(MAKE) -C $(FAKEROOT_HOST_BIARCH_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(FAKEROOT_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) -r $(FAKEROOT_HOST_TARGET_SCRIPT) $(FAKEROOT_HOST_DESTDIR)/bin/faked $(FAKEROOT_HOST_DESTDIR)/lib*/libfakeroot*

$(TOOL_FINISH)
