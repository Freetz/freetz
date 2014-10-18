SFK_VERSION:=1.6.5
SFK_VERSION_SHORT:=165
SFK_SOURCE:=sfk$(SFK_VERSION_SHORT).zip
SFK_SOURCE_MD5:=8694d73033dde496c023258f08daa918
SFK_SITE:=@SF/swissfileknife/1-swissfileknife/$(SFK_VERSION)
SFK_DIR:=$(TOOLS_SOURCE_DIR)/sfk$(SFK_VERSION_SHORT)
SFK_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)

sfk-source: $(DL_DIR)/$(SFK_SOURCE)
$(DL_DIR)/$(SFK_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SFK_SOURCE) $(SFK_SITE) $(SFK_SOURCE_MD5)

sfk-unpacked: $(SFK_DIR)/.unpacked
$(SFK_DIR)/.unpacked: $(DL_DIR)/$(SFK_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SFK_SOURCE),$(TOOLS_SOURCE_DIR))
	touch $@

$(SFK_DIR)/sfk: $(SFK_DIR)/.unpacked
ifeq ($(shell uname), Darwin)
	$(TOOLS_CXX) -DMAC_OS_X $(SFK_DIR)/sfk.cpp $(SFK_DIR)/sfknet.cpp $(SFK_DIR)/patch.cpp $(SFK_DIR)/inst.cpp -o $(SFK_DIR)/sfk
else
	$(TOOLS_CXX) -s $(SFK_DIR)/sfk.cpp $(SFK_DIR)/sfknet.cpp $(SFK_DIR)/patch.cpp $(SFK_DIR)/inst.cpp -o $(SFK_DIR)/sfk
endif

$(TOOLS_DIR)/sfk: $(SFK_DIR)/sfk
	$(INSTALL_FILE)

sfk: $(TOOLS_DIR)/sfk

sfk-clean:
	$(RM) $(SFK_DIR)/sfk

sfk-dirclean:
	$(RM) -r $(SFK_DIR)

sfk-distclean: sfk-dirclean
	$(RM) $(TOOLS_DIR)/sfk
