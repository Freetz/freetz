#
# pkcs11 is a header only library
#
# we've just packed together all headers files from
# ftp://ftp.rsasecurity.com/pub/pkcs/pkcs-11/v2-20/
#
$(call PKG_INIT_LIB, 2.20)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=232bde228c7af1960f8ef5df6ff19fbb
$(PKG)_SITE:=http://freetz.magenbrot.net

$(PKG)_HEADER:=$($(PKG)_DIR)/$(pkg).h
$(PKG)_STAGING_HEADER:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/$(pkg)/$(pkg).h

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_HEADER): $($(PKG)_DIR)/.configured
	@touch $@

$($(PKG)_STAGING_HEADER): $($(PKG)_HEADER)
	mkdir -p $(dir $@)
	cp $(dir $<)/*.h $(dir $@)
	@touch $@

$(pkg): $($(PKG)_STAGING_HEADER)

$(pkg)-precompiled: $($(PKG)_STAGING_HEADER)

$(pkg)-clean:
	$(RM) -r $(dir $(PKCS11_STAGING_HEADER))

$(pkg)-uninstall:

$(PKG_FINISH)
