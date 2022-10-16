$(call PKG_INIT_LIB, 1.41)
$(PKG)_LIB_VERSION:=12.6.4
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=884d706364b81abdd17bee9686d8ff2ae7431c5a14651047c68adf8b31fd8945
$(PKG)_SITE:=@GNU/$(pkg)
### WEBSITE:=https://www.gnu.org/software/libidn/
### MANPAGE:=https://www.gnu.org/software/libidn/manual/libidn.html
### CHANGES:=https://git.savannah.gnu.org/gitweb/?p=libidn.git;a=blob_plain;f=NEWS;hb=HEAD
### CVSREPO:=https://git.savannah.gnu.org/gitweb/?p=libidn.git

$(PKG)_LIBNAME_SHORT := $(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_LIB)/$(pkg).so.$($(PKG)_LIB_VERSION)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBIDN_DIR) all
	@touch $@

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBIDN_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(LIBIDN_LIBNAME_SHORT).la


$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBIDN_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$(LIBIDN_LIBNAME_SHORT)*

$(pkg)-uninstall:
	$(RM) $(LIBIDN_DEST_LIB)/$(LIBIDN_LIBNAME_SHORT).so*

$(PKG_FINISH)
