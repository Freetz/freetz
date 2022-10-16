$(call PKG_INIT_BIN, 1.48.04)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-source.zip
$(PKG)_HASH:=bf9a17673adffcc28ff7ea18764f06136547e97bbd9edf2ec612f09b207f0659
$(PKG)_SITE:=@SF/espeak

$(PKG)_PATCH_POST_CMDS += $(RM) -r linux_32bit;
$(PKG)_PATCH_POST_CMDS += find . -type f -exec chmod 644 {} \+;

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_ESPEAK_ALL_LANGUAGES

$(PKG)_BINARY:=$($(PKG)_DIR)/src/speak
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/speak

# not included in the target image, necessary only for creating index-files for big-endian boxes
# TODO: understand & modify espeak-phoneme-data.c so that it's possible to create
#       big-endian index-files on little-endian hosts (i.e. while cross-compiling)
$(PKG)_SWAP_BINARY:=$($(PKG)_DIR)/platforms/big_endian/espeak-phoneme-data

$(PKG)_TARGET_PHONDATA:=$($(PKG)_DEST_DIR)/usr/share/espeak-data/phondata

# TODO: working assumption - index-files could be recompiled to contain only required languages
#       found out how to do it and implement it
define espeak-data/files/common
voices/!v/*
intonations
phondata-manifest
phondata
phonindex
phontab
endef

define espeak-data/files/de
de_dict
mbrola_ph/de*_phtrans
voices/de
voices/mb/mb-de?
endef

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ESPEAK_DIR)/src \
		AUDIO="" \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		speak

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SWAP_BINARY): $($(PKG)_DIR)/.configured
	mkdir -p $(ESPEAK_DIR)/platforms/big_endian/{in,out}
	cp -a $(ESPEAK_DIR)/espeak-data/phon* $(ESPEAK_DIR)/platforms/big_endian/in/
	$(SUBMAKE) -C $(ESPEAK_DIR)/platforms/big_endian \
		CC="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_DIR)/.exclude_data: $($(PKG)_DIR)/.configured
	@$(if $(FREETZ_PACKAGE_ESPEAK_ALL_LANGUAGES),touch $@,$(call fileset-complement,$(ESPEAK_DIR)/espeak-data,$(call newline2space,$(espeak-data/files/common)) $(call newline2space,$(espeak-data/files/de))) > $@)

$($(PKG)_TARGET_PHONDATA): $($(PKG)_DIR)/.exclude_data
	@mkdir -p $(dir $@); \
	$(call COPY_USING_TAR,$(ESPEAK_DIR)/espeak-data,$(dir $@),--exclude-from=$< .) \
	$(if $(FREETZ_PACKAGE_ESPEAK_ALL_LANGUAGES),,$(call COPY_USING_TAR,$(ESPEAK_MAKE_DIR)/files-german,$(ESPEAK_DEST_DIR))) \
	$(if $(FREETZ_TARGET_ARCH_BE),$(call COPY_USING_TAR,$(ESPEAK_MAKE_DIR)/files-big-endian,$(ESPEAK_DEST_DIR))) \
	find $(dir $@) -type d -empty -delete; \
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_SWAP_BINARY)  $($(PKG)_TARGET_PHONDATA)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ESPEAK_DIR)/src clean
	-$(SUBMAKE) -C $(ESPEAK_DIR)/platforms/big_endian clean

$(pkg)-uninstall:
	$(RM) -r $(ESPEAK_TARGET_BINARY) $(dir $(ESPEAK_TARGET_PHONDATA))

$(PKG_FINISH)
