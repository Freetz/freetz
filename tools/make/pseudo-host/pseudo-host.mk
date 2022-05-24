$(call TOOLS_INIT, 0cda3ba5f94aed8d50652a99ee9c502975aa2926)
# Newer versions build with Ubuntu 14 and 18 cause problems on other systems with tar-host: https://github.com/Freetz-NG/freetz-ng/issues/468
$(PKG)_SOURCE:=pseudo-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=405652c57ed80f9230c7be213350c0bf51aeb8a4d629778b338160dd25cbf642
$(PKG)_SITE:=git@https://git.yoctoproject.org/git/pseudo
#$(PKG)_SITE:=http://downloads.yoctoproject.org/releases/pseudo/
### WEBSITE:=https://www.yoctoproject.org/software-item/pseudo/
### MANPAGE:=https://manpages.debian.org/testing/pseudo/pseudo.1.en.html
### CHANGES:=http://git.yoctoproject.org/cgit.cgi/pseudo/log/?h=oe-core
### CVSREPO:=http://git.yoctoproject.org/cgit.cgi/pseudo/

$(PKG)_MAINARCH_NAME:=arch
$(PKG)_BIARCH_NAME:=biarch

$(PKG)_MAINARCH_DIR:=$($(PKG)_DIR)/$($(PKG)_MAINARCH_NAME)
$(PKG)_BIARCH_DIR:=$($(PKG)_DIR)/$($(PKG)_BIARCH_NAME)

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
$(PKG)_MAINARCH_LD_PRELOAD_PATH:=$($(PKG)_DESTDIR)/lib
$(PKG)_BIARCH_LD_PRELOAD_PATH:=$($(PKG)_DESTDIR)/lib64
$(PKG)_TARGET_MAINARCH_LIB:=$($(PKG)_MAINARCH_LD_PRELOAD_PATH)/libpseudo.so
$(PKG)_TARGET_BIARCH_LIB:=$($(PKG)_BIARCH_LD_PRELOAD_PATH)/libpseudo.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit pseudo support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# The correct condition here would be:
# (using 32-bit [tools/toolchains] [own/dl]) AND (any of the STRIP-options is selected) AND (host is 64-bit)
BIARCH_BUILD_SYSTEM:=$(filter-out 32,$(HOST_BITNESS))

$(PKG)_TARBALL_STRIP_COMPONENTS:=0
$(PKG)_PATCH_POST_CMDS := mv $(pkg_short)-* $($(PKG)_MAINARCH_NAME);
$(PKG)_PATCH_POST_CMDS += cp -a $($(PKG)_MAINARCH_NAME) $($(PKG)_BIARCH_NAME);

$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_MAINARCH_DIR)/.configured: $($(PKG)_DIR)/.unpacked
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
$($(PKG)_TARGET_MAINARCH_LIB): $($(PKG)_MAINARCH_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PSEUDO_HOST_MAINARCH_DIR) install-lib $(if $(BIARCH_BUILD_SYSTEM),,install-bin)
	touch $@

$($(PKG)_BIARCH_DIR)/.configured: $($(PKG)_DIR)/.unpacked
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
$($(PKG)_TARGET_BIARCH_LIB): $($(PKG)_BIARCH_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PSEUDO_HOST_BIARCH_DIR) install-lib install-bin
	touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_MAINARCH_LIB) $(if $(BIARCH_BUILD_SYSTEM),$($(PKG)_TARGET_BIARCH_LIB))


$(pkg)-clean:
	-$(MAKE) -C $(PSEUDO_HOST_MAINARCH_DIR) clean
	-$(MAKE) -C $(PSEUDO_HOST_BIARCH_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PSEUDO_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PSEUDO_HOST_DESTDIR)/bin/pseudo* $(PSEUDO_HOST_TARGET_MAINARCH_LIB) $(PSEUDO_HOST_TARGET_BIARCH_LIB)

$(TOOLS_FINISH)
