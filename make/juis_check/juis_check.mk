$(call PKG_INIT_BIN, 5e3342106f241f9378cb295fcccd41350a394ff6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=1d0a25867a2b7e8f4bff3cca67155fc633d95a4f8f526d24295f276cf1cc56a0
$(PKG)_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,juis
### WEBSITE:=https://github.com/PeterPawn/YourFritz/tree/main/juis
### MANPAGE:=https://github.com/PeterPawn/YourFritz/tree/main/juis#readme
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/main/juis
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/main/juis

$(PKG)_BINARY:=$($(PKG)_DIR)/juis/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(JUIS_CHECK_TARGET_BINARY)

$(PKG_FINISH)

