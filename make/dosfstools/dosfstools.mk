$(call PKG_INIT_BIN, 3.0.22)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=301f01ca8a734011c0257134bcf475c8
$(PKG)_SITE:=http://www.daniel-baumann.ch/files/software/dosfstools

$(PKG)_BINARIES_ALL := fsck.fat fatlabel mkfs.fat
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
$(PKG)_LIBS += -liconv
endif

# always compile with LFS enabled
$(PKG)_CFLAGS := $(subst $(CFLAGS_LARGEFILE),,$(TARGET_CFLAGS)) $(CFLAGS_LFS_ENABLED) -fomit-frame-pointer

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DOSFSTOOLS_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(DOSFSTOOLS_CFLAGS)" \
		LDFLAGS="$(DOSFSTOOLS_LIBS)" \
		all

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DOSFSTOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DOSFSTOOLS_BINARIES_ALL:%=$(DOSFSTOOLS_DEST_DIR)/usr/sbin/%)

$(PKG_FINISH)
