$(call PKG_INIT_BIN, 5.0.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=0fe158444818f64da731520e31dc09bd
$(PKG)_SITE:=@KERNEL/linux/daemons/$(pkg)/v5

$(PKG)_BINARY:=$($(PKG)_DIR)/daemon/automount
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/automount

$(PKG)_LIBRARIES_ALL := lookup_file.so \
	lookup_hosts.so \
	lookup_multi.so \
	lookup_program.so \
	lookup_userhome.so \
	mount_afs.so \
	mount_autofs.so \
	mount_bind.so \
	mount_changer.so \
	mount_generic.so \
	mount_nfs.so \
	parse_sun.so

$(PKG)_LIBRARIES := $($(PKG)_LIBRARIES_ALL)
$(PKG)_LIBS_BUILD_DIR := $($(PKG)_LIBRARIES:%=$($(PKG)_DIR)/modules/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBRARIES:%=$($(PKG)_DEST_LIBDIR)/%)


$(PKG)_BUILD_PREREQ += bison flex
$(PKG)_STARTLEVEL=50

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) daemon -C $(AUTOFS_DIR) \
		FREETZ=1 \
		CC="$(TARGET_CC)" \
		AUTOFS_CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/modules/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(AUTOFS_DIR) clean
	$(RM) $(AUTOFS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(AUTOFS_TARGET_BINARY)

$(PKG_FINISH)
