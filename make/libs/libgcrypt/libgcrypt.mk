$(call PKG_INIT_LIB, 1.10.1)
$(PKG)_LIB_VERSION:=20.4.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA256:=ef14ae546b0084cd84259f61a55e07a38c3b53afc0f546bffcef2f01baffe9de
$(PKG)_SITE:=https://gnupg.org/ftp/gcrypt/libgcrypt,ftp://ftp.gnupg.org/gcrypt/libgcrypt
### WEBSITE:=https://gnupg.org/software/libgcrypt/
### CHANGES:=https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgcrypt.git;a=blob;f=NEWS
### CVSREPO:=https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgcrypt.git

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_DIGESTS            := blake2 crc gostr3411-94 md2 md4 md5 rmd160 sha1 sha3 sha256 sha512 sm3 stribog tiger whirlpool
$(PKG)_SYMMETRIC_CIPHERS  := aes arcfour blowfish camellia cast5 chacha20 des gost28147 idea rfc2268 salsa20 seed serpent sm4 twofish
$(PKG)_ASYMMETRIC_CIPHERS := dsa ecc elgamal rsa
$(foreach i,DIGEST SYMMETRIC_CIPHER ASYMMETRIC_CIPHER, \
  $(eval $(PKG)_REBUILD_SUBOPTS += $(patsubst %,FREETZ_LIB_libgcrypt_WITH_$(call LEGAL_VARNAME,$(i))_%,$($(PKG)_$(i)S))) \
)

$(PKG)_DEPENDS_ON += libgpg-error

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-asm
$(PKG)_CONFIGURE_OPTIONS += --with-gpg-error-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-digests="$(call LIB_SELECTED_SUBOPTIONS,$($(PKG)_DIGESTS),WITH_DIGEST)"
$(PKG)_CONFIGURE_OPTIONS += --enable-ciphers="$(call LIB_SELECTED_SUBOPTIONS,$($(PKG)_SYMMETRIC_CIPHERS),WITH_SYMMETRIC_CIPHER)"
$(PKG)_CONFIGURE_OPTIONS += --enable-pubkey-ciphers="$(call LIB_SELECTED_SUBOPTIONS,$($(PKG)_ASYMMETRIC_CIPHERS),WITH_ASYMMETRIC_CIPHER)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBGCRYPT_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBGCRYPT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libgcrypt-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBGCRYPT_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/{libgcrypt-config,dumpsexp,hmac256} \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gcrypt* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/libgcrypt* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/info/gcrypt*

$(pkg)-uninstall:
	$(RM) $(LIBGCRYPT_TARGET_DIR)/libgcrypt*.so*

$(PKG_FINISH)
