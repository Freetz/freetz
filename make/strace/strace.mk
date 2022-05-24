$(call PKG_INIT_BIN, $(if $(FREETZ_KERNEL_VERSION_2_MAX),$(if $(FREETZ_KERNEL_VERSION_2_6_13),4.9,5.0),5.17))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_4.9:=095bfea5c540b91d297ccac73b21b92fd54a24599fd70395db87ff9eb7fd6f65
$(PKG)_HASH_5.0:=3b7ad77eb2b81dc6078046a9cc56eed5242b67b63748e7fc28f7c2daf4e647da
$(PKG)_HASH_5.17:=5fb298dbd1331fd1e1bc94c5c32395860d376101b87c6cd3d1ba9f9aa15c161f
$(PKG)_HASH:=$($(PKG)_HASH_$($(PKG)_VERSION))
$(PKG)_SITE:=https://www.strace.io/files/$($(PKG)_VERSION),@SF/$(pkg)
### WEBSITE:=https://www.strace.io/
### MANPAGE:=https://man7.org/linux/man-pages/man1/strace.1.html
### CHANGES:=https://www.strace.io/files/
### CVSREPO:=https://github.com/strace/strace

$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)

# MIPS definitions for SO_PROTOCOL / SO_DOMAIN in AVM kernel sources for 7390.06.5x-8x
# differ from that of vanilla sources because of incorrect backport.
# s. https://github.com/Freetz/freetz/issues/208 for more details
$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|CPP)FLAGS)
$(PKG)_EXTRA_CPPFLAGS += $(if $(and $(FREETZ_SYSTEM_TYPE_IKS),$(FREETZ_AVM_VERSION_06_5X_MIN)),-D_AVM_WRONG_SOCKET_OPTIONS_CODES=1)

$(PKG)_BINARY:=$($(PKG)_DIR)$(if $(FREETZ_KERNEL_VERSION_2_MAX),/,/src/)strace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/strace
$(PKG)_CATEGORY:=Debug helpers

$(PKG)_CONFIGURE_ENV += ac_cv_header_linux_netlink_h=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(STRACE_DIR) \
		EXTRA_CPPFLAGS="$(STRACE_EXTRA_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STRACE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STRACE_TARGET_BINARY)

$(PKG_FINISH)
