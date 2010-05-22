$(call PKG_INIT_BIN, 1.7.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=3da231dbe82ad103373cb530ae7475d5
$(PKG)_SITE:=http://www.kernel.org/pub/software/scm/$(pkg)

# files to be moved from /usr/lib/git-core to /usr/bin
$(PKG)_FILES_TO_MOVE := git-daemon
# files to be symlinked from /usr/lib/git-core to /usr/bin in order to reduce package size
$(PKG)_FILES_TO_SYMLINK := git git-shell git-upload-pack git-cvsserver $($(PKG)_FILES_TO_MOVE)

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/git
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/git

$(PKG)_DEPENDS_ON += curl expat openssl zlib
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
endif

$(PKG)_CONFIGURE_ENV += ac_cv_c_c99_format=yes
$(PKG)_CONFIGURE_ENV += ac_cv_fread_reads_directories=no
$(PKG)_CONFIGURE_ENV += ac_cv_snprintf_returns_bogus=no

$(PKG)_CONFIGURE_OPTIONS += --with-gitconfig=/tmp/flash/gitconfig
$(PKG)_CONFIGURE_OPTIONS += --enable-pthreads
$(PKG)_CONFIGURE_OPTIONS += --with-curl
$(PKG)_CONFIGURE_OPTIONS += --with-expat
$(PKG)_CONFIGURE_OPTIONS += --with-iconv
$(PKG)_CONFIGURE_OPTIONS += --with-openssl
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-perl
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-tcltk

$(PKG)_MAKE_PARAMS := V=1 NO_NSEC=1 STRIP="$(TARGET_STRIP)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	for target in all strip; do \
		$(SUBMAKE) -C $(GIT_DIR) $(GIT_MAKE_PARAMS) $$target; \
	done

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(SUBMAKE) -C $(GIT_DIR) $(GIT_MAKE_PARAMS) \
		DESTDIR=$(abspath $(GIT_DEST_DIR)) \
		install \
	&& \
	for binary in $(GIT_FILES_TO_MOVE); do \
		mv $(GIT_DEST_DIR)/usr/lib/git-core/$$binary $(GIT_DEST_DIR)/usr/bin/; \
	done \
	&& \
	for binary in $(GIT_FILES_TO_SYMLINK); do \
		rm -f $(GIT_DEST_DIR)/usr/lib/git-core/$$binary \
		&& ln -fs ../../bin/$$binary $(GIT_DEST_DIR)/usr/lib/git-core/; \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GIT_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(GIT_DEST_DIR)/usr/{bin,lib}/git*

$(PKG_FINISH)
