$(call PKG_INIT_BIN,0.3.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.michaeldenk.de/projects/hp-utils
$(PKG)_BINARY:=$($(PKG)_DIR)/hp-levels
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/hp-levels
$(PKG)_SOURCE_MD5:=f870752e105db811bf87577123353c58 

$(PKG)_DEPENDS_ON:= hplip

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(HP_UTILS_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="" \
		LDFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	cp $(HP_UTILS_DIR)/hp-clean $(HP_UTILS_DEST_DIR)/usr/bin
	cp $(HP_UTILS_DIR)/hp-faxsetup $(HP_UTILS_DEST_DIR)/usr/bin
	cp $(HP_UTILS_DIR)/hp-levels $(HP_UTILS_DEST_DIR)/usr/bin
	cp $(HP_UTILS_DIR)/hp-printserv $(HP_UTILS_DEST_DIR)/usr/bin
	cp $(HP_UTILS_DIR)/hp-probe $(HP_UTILS_DEST_DIR)/usr/bin
	cp $(HP_UTILS_DIR)/hp-status $(HP_UTILS_DEST_DIR)/usr/bin
	cp $(HP_UTILS_DIR)/hp-timedate $(HP_UTILS_DEST_DIR)/usr/bin
	cp -a $(HP_UTILS_DIR)/libhp-utils.so* $(HP_UTILS_DEST_DIR)/usr/lib
	$(TARGET_STRIP) $(HP_UTILS_DEST_DIR)/usr/bin/hp-clean \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-faxsetup \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-levels \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-printserv \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-probe \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-status \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-timedate \
		$(HP_UTILS_DEST_DIR)/usr/lib/libhp-utils.so.$(HP_UTILS_VERSION)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HP_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HP_UTILS_DEST_DIR)/usr/bin/hp-clean \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-faxsetup \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-levels \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-probe \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-status \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-printserv \
		$(HP_UTILS_DEST_DIR)/usr/bin/hp-timedate

$(PKG_FINISH)
