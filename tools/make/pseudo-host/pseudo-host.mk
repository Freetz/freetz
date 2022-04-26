$(call TOOL_INIT, 0cda3ba5f94aed8d50652a99ee9c502975aa2926)
# Newer versions build with Ubuntu 14 and 18 cause problems on other systems with tar-host: https://github.com/Freetz-NG/freetz-ng/issues/468
$(TOOL)_SOURCE:=pseudo-$($(TOOL)_VERSION).tar.xz
$(TOOL)_SOURCE_SHA256:=405652c57ed80f9230c7be213350c0bf51aeb8a4d629778b338160dd25cbf642
$(TOOL)_SITE:=git@https://git.yoctoproject.org/git/pseudo
#$(TOOL)_SITE:=http://downloads.yoctoproject.org/releases/pseudo/
### WEBSITE:=https://www.yoctoproject.org/software-item/pseudo/
### MANPAGE:=https://manpages.debian.org/testing/pseudo/pseudo.1.en.html
### CHANGES:=http://git.yoctoproject.org/cgit.cgi/pseudo/log/?h=oe-core
### CVSREPO:=http://git.yoctoproject.org/cgit.cgi/pseudo/

$(TOOL)_MAINARCH_DIR:=$($(TOOL)_DIR)/arch
$(TOOL)_BIARCH_DIR:=$($(TOOL)_DIR)/biarch

$(TOOL)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
$(TOOL)_MAINARCH_LD_PRELOAD_PATH:=$($(TOOL)_DESTDIR)/lib
$(TOOL)_BIARCH_LD_PRELOAD_PATH:=$($(TOOL)_DESTDIR)/lib64
$(TOOL)_TARGET_MAINARCH_LIB:=$($(TOOL)_MAINARCH_LD_PRELOAD_PATH)/libpseudo.so
$(TOOL)_TARGET_BIARCH_LIB:=$($(TOOL)_BIARCH_LD_PRELOAD_PATH)/libpseudo.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit pseudo support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# The correct condition here would be:
# (using 32-bit [tools/toolchains] [own/dl]) AND (any of the STRIP-options is selected) AND (host is 64-bit)
BIARCH_BUILD_SYSTEM:=$(filter-out 32,$(HOST_BITNESS))


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PSEUDO_HOST_SOURCE) $(PSEUDO_HOST_SITE) $(PSEUDO_HOST_SOURCE_SHA256)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(PSEUDO_HOST_MAINARCH_DIR) $(PSEUDO_HOST_BIARCH_DIR)
	mkdir -p $(PSEUDO_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(PSEUDO_HOST_SOURCE),$(PSEUDO_HOST_DIR))
	mv $(PSEUDO_HOST_DIR)/pseudo-* $(PSEUDO_HOST_MAINARCH_DIR)
	$(call APPLY_PATCHES,$(PSEUDO_HOST_MAKE_DIR)/patches,$(PSEUDO_HOST_MAINARCH_DIR))
	cp -a $(PSEUDO_HOST_MAINARCH_DIR) $(PSEUDO_HOST_BIARCH_DIR)
	touch $@

$($(TOOL)_MAINARCH_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(PSEUDO_HOST_MAINARCH_DIR); $(RM) Makefile; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(PSEUDO_HOST_DESTDIR) \
		--enable-xattr=no \
		$(if $(BIARCH_BUILD_SYSTEM),--bits=32) \
		--cflags="-Wno-cast-function-type -Wno-nonnull-compare -fcommon $(if $(BIARCH_BUILD_SYSTEM),$(HOST_CFLAGS_FORCE_32BIT_CODE))" \
		--libdir=$(PSEUDO_HOST_MAINARCH_LD_PRELOAD_PATH) \
		$(SILENT) \
	);
	touch $@
$($(TOOL)_TARGET_MAINARCH_LIB): $($(TOOL)_MAINARCH_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(PSEUDO_HOST_MAINARCH_DIR) install-lib $(if $(BIARCH_BUILD_SYSTEM),,install-bin)
	touch $@

$($(TOOL)_BIARCH_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
	(cd $(PSEUDO_HOST_BIARCH_DIR); $(RM) Makefile; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) $(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(PSEUDO_HOST_DESTDIR) \
		--enable-xattr=no \
		--bits=$(HOST_BITNESS) \
		--cflags="-Wno-cast-function-type -Wno-nonnull-compare -fcommon" \
		--libdir=$(PSEUDO_HOST_BIARCH_LD_PRELOAD_PATH) \
		$(SILENT) \
	);
	touch $@
$($(TOOL)_TARGET_BIARCH_LIB): $($(TOOL)_BIARCH_DIR)/.configured
	$(TOOL_SUBMAKE) -C $(PSEUDO_HOST_BIARCH_DIR) install-lib install-bin
	touch $@

$(tool)-precompiled: $($(TOOL)_TARGET_MAINARCH_LIB) $(if $(BIARCH_BUILD_SYSTEM),$($(TOOL)_TARGET_BIARCH_LIB))


$(tool)-clean:
	-$(MAKE) -C $(PSEUDO_HOST_MAINARCH_DIR) clean
	-$(MAKE) -C $(PSEUDO_HOST_BIARCH_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(PSEUDO_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
	$(RM) -r $(PSEUDO_HOST_DESTDIR)/bin/pseudo* $(PSEUDO_HOST_TARGET_MAINARCH_LIB) $(PSEUDO_HOST_TARGET_BIARCH_LIB)

$(TOOL_FINISH)
