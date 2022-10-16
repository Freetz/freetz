// vi: set tabstop=4 syntax=c :
/***********************************************************************
 *                                                                     *
 *                                                                     *
 * Copyright (C) 2016 P.Hämmerlein (http://www.yourfritz.de)           *
 * Modified by Eugene Rudoy (https://github.com/er13)                  *
 *                                                                     *
 * This program is free software; you can redistribute it and/or       *
 * modify it under the terms of the GNU General Public License         *
 * as published by the Free Software Foundation; either version 2      *
 * of the License, or (at your option) any later version.              *
 *                                                                     *
 * This program is distributed in the hope that it will be useful,     *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of      *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       *
 * GNU General Public License for more details.                        *
 *                                                                     *
 * You should have received a copy of the GNU General Public License   *
 * along with this program, please look for the file COPYING.          *
 *                                                                     *
 ***********************************************************************/

#include <stdlib.h>
#include <stdio.h>

#include <libfdt.h>

#include "lib_avm_kernel_config.h"
#include "memory_mapped_file.h"

void usage()
{

	fprintf(stderr, "avm_kernel_config.bin2asm - generate a kernel config source file\n\n");
	fprintf(stderr, "(C) 2016 P. Hämmerlein (http://www.yourfritz.de)\n");
	fprintf(stderr, "Modified by Eugene Rudoy for Freetz project (https://freetz.github.io)\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "Licensed under GPLv2, see LICENSE file from source repository.\n\n");
	fprintf(stderr, "Usage:\n\n");
	fprintf(stderr, "avm_kernel_config.bin2asm <binary_config_area_file>\n");
	fprintf(stderr, "\nThe configuration area dump is read and an assembler source file");
	fprintf(stderr, "\nis created from its content. This file may later be compiled into");
	fprintf(stderr, "\nan object file ready to be included into an own kernel while");
	fprintf(stderr, "\nlinking it.\n");
	fprintf(stderr, "\nThe output is written to STDOUT, so you've to redirect it to the");
	fprintf(stderr, "\nproper location.\n");

}

void processDeviceTreeEntry(struct _avm_kernel_config* entry, unsigned int subRev)
{
	if (!isDeviceTreeEntry(entry))
		return;

	fprintf(stdout, "\n"); // empty line as optical delimiter in front of DTB dump
	fprintf(stdout, ".L_avm_device_tree_subrev_%u:\n", subRev);
	fprintf(stdout, "\tAVM_DEVICE_TREE_BLOB\t%u\n", subRev);

	uint32_t dtbSize = fdt_totalsize(entry->config);
	register uint8_t * source = (uint8_t *) entry->config;
	while (dtbSize > 0)
	{
		uint32_t i = (dtbSize > 16 ? 16 : dtbSize);
		dtbSize -= i;

		fprintf(stdout, "\t.byte\t");
		while (i--) fprintf(stdout, "0x%02x%c", *(source++), (i ? ',' : '\n'));
	}
}

void processVersionInfoEntry(struct _avm_kernel_config* entry)
{
	if (entry == NULL)
		return;
	if (entry->tag != avm_kernel_config_tags_version_info)
		return;

	struct _avm_kernel_version_info * version = (struct _avm_kernel_version_info *) entry->config;
	fprintf(stdout, "\n\tAVM_VERSION_INFO\t\"%s\", \"%s\", \"%s\"\n", version->buildnumber, version->svnversion, version->firmwarestring);
}

void processModuleMemoryEntry(struct _avm_kernel_config* entry, uint32_t moduleStructSize)
{
	if (entry == NULL)
		return;
	if (entry->tag != avm_kernel_config_tags_modulememory)
		return;

	int mod_no = 0;

	fprintf(stdout, "\n.L_avm_module_memory:\n");

	if (moduleStructSize == 2) {
		struct _kernel_modulmemory_config2 * module = (struct _kernel_modulmemory_config2 *) entry->config;
		while (module->name != NULL)
		{
			fprintf(stdout, "\tAVM_MODULE_MEMORY\t%u, \"%s\", %u\n", ++mod_no, module->name, module->size);
			module++;
		}
		fprintf(stdout, "\tAVM_MODULE_MEMORY\t0\n");
	} else if (moduleStructSize == 4) {
		struct _kernel_modulmemory_config4 * module = (struct _kernel_modulmemory_config4 *) entry->config;
		while (module->name != NULL)
		{
			fprintf(stdout, "\tAVM_MODULE_MEMORY4\t%u, \"%s\", %u, %u, %u\n", ++mod_no, module->name, module->size, module->symbol_size, module->symbol_text_size);
			module++;
		}
		fprintf(stdout, "\tAVM_MODULE_MEMORY4\t0\n");
	}
}

#define AVM_KERNEL_CONFIG_TAGS_MAX ((enum _avm_kernel_config_tags)(~(uint32_t)0))
void derive_avm_kernel_config_tags(
	struct _avm_kernel_config*   *configArea,
	enum _avm_kernel_config_tags *device_tree_subrev_0,
	enum _avm_kernel_config_tags *last
) {
	// device tree for subrevision 0 is the fallback entry and may be considered as 'always present', if FDTs exist at all
	*device_tree_subrev_0 = AVM_KERNEL_CONFIG_TAGS_MAX;
	*last                 = AVM_KERNEL_CONFIG_TAGS_MAX;

	if (*configArea != NULL)
	{
		struct _avm_kernel_config *entry;
		for (entry = *configArea; entry->config != NULL; entry++)
		{
			if (isDeviceTreeEntry(entry))
			{
				// smallest tag is assumed to be device_tree_subrev_0
				if (entry->tag < *device_tree_subrev_0)
					*device_tree_subrev_0 = entry->tag;
			}
		}

		*last = entry->tag;
	}
}

int processConfigArea(struct _avm_kernel_config * *configArea, uint32_t moduleStructSize)
{
	struct _avm_kernel_config *moduleMemoryEntry = findEntryByTag(configArea, avm_kernel_config_tags_modulememory);
	struct _avm_kernel_config *versionInfoEntry  = findEntryByTag(configArea, avm_kernel_config_tags_version_info);

	enum _avm_kernel_config_tags derived_device_tree_subrev_0;
	enum _avm_kernel_config_tags derived_last;
	derive_avm_kernel_config_tags(configArea, &derived_device_tree_subrev_0, &derived_last);
#if !defined(USE_STRIPPED_AVM_KERNEL_CONFIG_H)
	if (derived_device_tree_subrev_0 != avm_kernel_config_tags_device_tree_subrev_0)
	{
		fprintf(stderr, "derived_device_tree_subrev_0 is expected to be equal to avm_kernel_config_tags_device_tree_subrev_0. Check the reasons and adjust the code if necessary.\n");
		exit(2);
	}
	if (derived_last != avm_kernel_config_tags_last)
	{
		fprintf(stderr, "derived_last is expected to be equal to avm_kernel_config_tags_last. Check the reasons and adjust the code if necessary.\n");
		exit(2);
	}
#endif

	fprintf(stdout, "#include \"avm_kernel_config_macros.h\"\n\n");

	fprintf(stdout, "\tAVM_KERNEL_CONFIG_START\n\n");
	fprintf(stdout, "\tAVM_KERNEL_CONFIG_PTR\n\n");
	fprintf(stdout, ".L_avm_kernel_config_entries:\n");

	if (moduleMemoryEntry)
		fprintf(stdout, "\tAVM_KERNEL_CONFIG_ENTRY\t%u, \"module_memory\"\n", avm_kernel_config_tags_modulememory);
	if (versionInfoEntry)
		fprintf(stdout, "\tAVM_KERNEL_CONFIG_ENTRY\t%u, \"version_info\"\n", avm_kernel_config_tags_version_info);

	for (struct _avm_kernel_config * entry = *configArea; entry->config != NULL; entry++)
	{
		if (isDeviceTreeEntry(entry))
		{
			fprintf(stdout, "\tAVM_KERNEL_CONFIG_ENTRY\t%u, \"device_tree_subrev_%u\"\n", entry->tag, entry->tag - derived_device_tree_subrev_0);
		}
	}

	fprintf(stdout, "\tAVM_KERNEL_CONFIG_ENTRY\t%u, NULL\n", derived_last);

	for (struct _avm_kernel_config * entry = *configArea; entry->config != NULL; entry++)
	{
		if (isDeviceTreeEntry(entry))
		{
			processDeviceTreeEntry(entry, entry->tag - derived_device_tree_subrev_0);
		}
	}
	processVersionInfoEntry(versionInfoEntry);
	processModuleMemoryEntry(moduleMemoryEntry, moduleStructSize);

	fprintf(stdout, "\n\tAVM_KERNEL_CONFIG_END\n\n");

	return 0;
}

int main(int argc, char * argv[])
{
	int returnCode = 1;
	struct memoryMappedFile input;

	if (argc < 2)
	{
		usage();
		exit(1);
	}

	if (openMemoryMappedFile(&input, argv[1], "input", O_RDONLY | O_SYNC, PROT_WRITE, MAP_PRIVATE))
	{
		uint32_t moduleStructSize;
		struct _avm_kernel_config ** configArea = relocateConfigArea(input.fileBuffer, input.fileStat.st_size, &moduleStructSize);

		if (configArea != NULL)
		{
			returnCode = processConfigArea(configArea, moduleStructSize);
		}
		else
		{
			fprintf(stderr, "Unable to identify and relocate the specified config area dump file, may be it's empty.\n");
			returnCode = 1;
		}
		closeMemoryMappedFile(&input);
	}

	exit(returnCode);
}
