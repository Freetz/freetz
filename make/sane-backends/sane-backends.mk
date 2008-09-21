SANE_BACKENDS=
ifeq ($(strip $(FREETZ_SANE_BACKEND_abaton)),y)
SANE_BACKENDS+=abaton
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_agfafocus)),y)
SANE_BACKENDS+=agfafocus
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_apple)),y)
SANE_BACKENDS+=apple
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_artec)),y)
SANE_BACKENDS+=artec
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_artec_eplus48u)),y)
SANE_BACKENDS+=artec_eplus48u
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_as6e)),y)
SANE_BACKENDS+=as6e
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_avision)),y)
SANE_BACKENDS+=avision
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_bh)),y)
SANE_BACKENDS+=bh
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_canon)),y)
SANE_BACKENDS+=canon
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_canon630u)),y)
SANE_BACKENDS+=canon630u
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_cardscan)),y)
SANE_BACKENDS+=cardscan
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_coolscan)),y)
SANE_BACKENDS+=coolscan
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_coolscan2)),y)
SANE_BACKENDS+=coolscan2
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_dc25)),y)
SANE_BACKENDS+=dc25
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_dmc)),y)
SANE_BACKENDS+=dmc
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_epjitsu)),y)
SANE_BACKENDS+=epjitsu
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_epson)),y)
SANE_BACKENDS+=epson
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_epson2)),y)
SANE_BACKENDS+=epson2
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_fujitsu)),y)
SANE_BACKENDS+=fujitsu
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_genesys)),y)
SANE_BACKENDS+=genesys
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_gt68xx)),y)
SANE_BACKENDS+=gt68xx
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_hp)),y)
SANE_BACKENDS+=hp
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_hp3500)),y)
SANE_BACKENDS+=hp3500
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_hp3900)),y)
SANE_BACKENDS+=hp3900
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_hp4200)),y)
SANE_BACKENDS+=hp4200
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_hp5400)),y)
SANE_BACKENDS+=hp5400
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_hp5590)),y)
SANE_BACKENDS+=hp5590
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_hpljm1005)),y)
SANE_BACKENDS+=hpljm1005
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_hs2p)),y)
SANE_BACKENDS+=hs2p
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_ibm)),y)
SANE_BACKENDS+=ibm
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_leo)),y)
SANE_BACKENDS+=leo
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_lexmark)),y)
SANE_BACKENDS+=lexmark
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_ma1509)),y)
SANE_BACKENDS+=ma1509
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_matsushita)),y)
SANE_BACKENDS+=matsushita
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_microtek)),y)
SANE_BACKENDS+=microtek
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_microtek2)),y)
SANE_BACKENDS+=microtek2
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_mustek)),y)
SANE_BACKENDS+=mustek
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_mustek_usb)),y)
SANE_BACKENDS+=mustek_usb
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_nec)),y)
SANE_BACKENDS+=nec
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_niash)),y)
SANE_BACKENDS+=niash
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_pie)),y)
SANE_BACKENDS+=pie
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_pixma)),y)
SANE_BACKENDS+=pixma
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_plustek)),y)
SANE_BACKENDS+=plustek
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_ricoh)),y)
SANE_BACKENDS+=ricoh
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_s9036)),y)
SANE_BACKENDS+=s9036
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_sceptre)),y)
SANE_BACKENDS+=sceptre
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_sharp)),y)
SANE_BACKENDS+=sharp
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_sm3600)),y)
SANE_BACKENDS+=sm3600
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_sm3840)),y)
SANE_BACKENDS+=sm3840
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_snapscan)),y)
SANE_BACKENDS+=snapscan
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_sp15c)),y)
SANE_BACKENDS+=sp15c
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_st400)),y)
SANE_BACKENDS+=st400
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_stv680)),y)
SANE_BACKENDS+=stv680
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_tamarack)),y)
SANE_BACKENDS+=tamarack
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_teco1)),y)
SANE_BACKENDS+=teco1
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_teco2)),y)
SANE_BACKENDS+=teco2
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_teco3)),y)
SANE_BACKENDS+=teco3
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_test)),y)
SANE_BACKENDS+=test
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_u12)),y)
SANE_BACKENDS+=u12
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_umax)),y)
SANE_BACKENDS+=umax
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_umax_pp)),y)
SANE_BACKENDS+=umax_pp
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_umax1220u)),y)
SANE_BACKENDS+=umax1220u
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_plustek_pp)),y)
SANE_BACKENDS+=plustek_pp
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_dc210)),y)
SANE_BACKENDS+=dc210
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_dc240)),y)
SANE_BACKENDS+=dc240
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_qcam)),y)
SANE_BACKENDS+=qcam
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_v4l)),y)
SANE_BACKENDS+=v4l
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_net)),y)
SANE_BACKENDS+=net
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_mustek_usb2)),y)
SANE_BACKENDS+=mustek_usb2
endif

ifeq ($(strip $(FREETZ_SANE_BACKEND_dll)),y)
SANE_BACKENDS+=dll
endif

$(call PKG_INIT_BIN,1.0.19)
$(PKG)_LIB_VERSION:=1.0.19
$(PKG)_SOURCE:=sane-backends-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp2.sane-project.org/pub/sane/sane-backends-1.0.19

#saned
$(PKG)_TARGET_saned:=$($(PKG)_DEST_DIR)/usr/sbin/saned
$(PKG)_saned:=$($(PKG)_DIR)/frontend/.libs/saned

# sane-find-scanner
$(PKG)_TARGET_sane_find_scanner:=$($(PKG)_DEST_DIR)/usr/bin/sane-find-scanner
$(PKG)_sane_find_scanner:=$($(PKG)_DIR)/tools/sane-find-scanner

# scanimage
$(PKG)_TARGET_scanimage:=$($(PKG)_DEST_DIR)/usr/bin/scanimage
$(PKG)_scanimage:=$($(PKG)_DIR)/frontend/.libs/scanimage

# libsane
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/backend/.libs/libsane.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsane.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=root/usr/lib/libsane.so.$($(PKG)_LIB_VERSION)


$(PKG)_TARGET_BINARIES:=$($(PKG)_TARGET_saned)
ifeq ($(strip $(FREETZ_SANE_sane_find_scanner)),y)
$(PKG)_TARGET_BINARIES+=$($(PKG)_TARGET_sane_find_scanner)
endif
ifeq ($(strip $(FREETZ_SANE_scanimage)),y)
$(PKG)_TARGET_BINARIES+=$($(PKG)_TARGET_scanimage)
endif

$(PKG)_DEPENDS_ON:=jpeg
$(PKG)_DEPENDS_ON:=libusb

$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6 --disable-translations
$(PKG)_CONFIGURE_ENV+=BACKENDS="$(SANE_BACKENDS)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_saned) $($(PKG)_sane_find_scanner) $($(PKG)_scanimage) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(SANE_BACKENDS_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(SANE_BACKENDS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		freetz-install-devel
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libsane.la

$($(PKG)_TARGET_saned): $($(PKG)_saned)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_sane_find_scanner): $($(PKG)_sane_find_scanner)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_scanimage): $($(PKG)_scanimage)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsane*.so* root/usr/lib
	$(TARGET_STRIP) $@

$(PKG)_LIB_TARGET_BACKENDS_BINARIES:
	mkdir -p $(SANE_BACKENDS_DEST_DIR)/usr/lib/sane
	cp -a $(SANE_BACKENDS_DIR)/backend/.libs/libsane-*.so* $(SANE_BACKENDS_DEST_DIR)/usr/lib/sane
	$(TARGET_STRIP) $(SANE_BACKENDS_DEST_DIR)/usr/lib/sane/*
.PHONY: $(PKG)_LIB_TARGET_BACKENDS_BINARIES

$(PKG)_TARGET_CONF:
	mkdir -p $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends
	cp -a $(SANE_BACKENDS_DIR)/backend/*.conf $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends
	$(RM) $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends/saned.conf
	$(RM) $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends/dll.conf
	for backend in $(SANE_BACKENDS); do \
		if [ "$$backend" != "dll" ]; then \
			echo $$backend >> $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends/dll.conf; \
		fi; \
	done
.PHONY: $(PKG)_TARGET_CONF

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARIES) $($(PKG)_LIB_TARGET_BINARY) $(PKG)_LIB_TARGET_BACKENDS_BINARIES $(PKG)_TARGET_CONF

$(pkg)-clean:
	-$(MAKE) -C $(SANE_BACKENDS_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsane* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sane

$(pkg)-uninstall:
	$(RM) -r $($(PKG)_TARGET_saned) \
		$($(PKG)_TARGET_sane_find_scanner) \
		$($(PKG)_TARGET_scanimage) \
		$($(PKG)_LIB_TARGET_BACKENDS_BINARIES)

$(PKG_FINISH)
