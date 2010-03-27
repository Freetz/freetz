$(call PKG_INIT_BIN, 3.0.24)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=89273f67a6d8067cbbecefaa13747153
$(PKG)_SITE:=ftp://de3.$(pkg).org/pub/$(pkg)/old-versions

$(PKG)_STARTLEVEL=80

$(PKG)_BINARIES_ALL := smbpasswd smbd nmbd
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_NMBD),,nmbd),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/source/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/sbin/%)
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SAMBA_DIR)/source \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		AR="$(TARGET_CROSS)ar" \
		TARGETFS="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		SAMBA_CFLAGS="$(TARGET_CFLAGS)" \
		CODEPAGEDIR="/mod/usr/share/samba" \
		proto all

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%: $($(PKG)_DIR)/source/bin/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SAMBA_DIR)/source clean
	$(RM) -r $(SAMBA_DIR)/source/bin

$(pkg)-uninstall:
	$(RM) $(SAMBA_BINARIES_ALL:%=$(SAMBA_DEST_DIR)/sbin/%)

$(PKG_FINISH)
