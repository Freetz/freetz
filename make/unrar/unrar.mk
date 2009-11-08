$(call PKG_INIT_BIN, 3.9.6)
$(PKG)_DIR:=$(subst -$($(PKG)_VERSION),,$($(PKG)_DIR))
$(PKG)_SOURCE:=unrarsrc-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.rarlab.com/rar/
$(PKG)_BINARY:=$($(PKG)_DIR)/unrar
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/unrar
$(PKG)_SOURCE_MD5:=59b23dd05ff70791cd6449effa7fc3b6

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_UNRAR_STATIC
ifeq ($(strip $(FREETZ_PACKAGE_UNRAR_STATIC)),y)
$(PKG)_LDFLAGS:="-static"
else
$(PKG)_LDFLAGS:=""
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UNRAR_DIR) -f makefile.unix \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		DEFINES="" \
		LDFLAGS="$(UNRAR_LDFLAGS)" \
		STRIP="$(TARGET_STRIP)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UNRAR_DIR) -f makefile.unix clean

$(pkg)-uninstall:
	$(RM) $(UNRAR_TARGET_BINARY)

$(PKG_FINISH)
