#
# recent versions of strace do not support older kernel versions anymore,
# that's the reason we have to stick to an older strace version for kernel versions 2.6.13 & 2.6.19
#
$(call PKG_INIT_BIN, $(if $(FREETZ_KERNEL_VERSION_2_6_19_MAX),4.8,4.22))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5_4.8 :=c575ef43829586801f514fd91bfe7575
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
	$(SUBMAKE) -C $(STRACE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STRACE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STRACE_TARGET_BINARY)

$(PKG_FINISH)
