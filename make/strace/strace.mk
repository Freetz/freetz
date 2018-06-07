#
# recent versions of strace do not support older kernel versions anymore,
# that's the reason we have to stick to an older strace version for kernel versions 2.6.13 & 2.6.19
#
STRACE_VERSION__KERNEL_2.6.13:=4.9
STRACE_VERSION__KERNEL_2.6.19:=4.10

$(call PKG_INIT_BIN, $(or $(strip $(STRACE_VERSION__KERNEL_$(call qstrip,$(FREETZ_KERNEL_VERSION_MAJOR)))),4.22))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5_4.9 :=885eafadb10f6c60464a266d3929a2a4
$(PKG)_SOURCE_MD5_4.10:=107a5be455493861189e9b57a3a51912
$(PKG)_SOURCE_MD5_4.22:=7a2a7d7715da6e6834bc65bd09bace1c
$(PKG)_SOURCE_MD5:=$($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))
$(PKG)_SITE:=@SF/$(pkg),https://strace.io/files/$($(PKG)_VERSION)

$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/strace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/strace
$(PKG)_CATEGORY:=Debug helpers

$(PKG)_CONFIGURE_ENV += ac_cv_header_linux_netlink_h=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(STRACE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STRACE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STRACE_TARGET_BINARY)

$(PKG_FINISH)
