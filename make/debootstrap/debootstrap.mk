$(call PKG_INIT_BIN, 0.3.3.2etch1)
#
# The only binary needed for debootstrap is 'pkgdetails'. In newer debian revisions
# is has moved from package 'debootstrap' to 'base_installer', however, the source
# code didn't changed. So we use an ancient version of debootstrap sources to build
# this binary.
# All other files are extracted from the current debootstrap source, at the time of
# writing this comment this is version 1.0.10.
#
$(PKG)_SOURCE:=debootstrap_$(DEBOOTSTRAP_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/d/debootstrap
$(PKG)_BINARY:=$($(PKG)_DIR)/pkgdetails
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/debootstrap/pkgdetails
$(PKG)_SOURCE_MD5:=f8172809afe7cfdcdc6745229f024d9d 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	cd $(DEBOOTSTRAP_DIR) && $(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CC) $(TARGET_CFLAGS) -o pkgdetails pkgdetails.c

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(DEBOOTSTRAP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DEBOOTSTRAP_TARGET_BINARY)

$(PKG_FINISH)
