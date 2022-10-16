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

static void swapEndianness(bool needed, uint32_t *ptr)
{
	if (!needed)
		return;

	*ptr =	(*ptr & 0x000000FF) << 24 |
			(*ptr & 0x0000FF00) << 8 |
			(*ptr & 0x00FF0000) >> 8 |
			(*ptr & 0xFF000000) >> 24;
}

bool isConsistentConfigArea(void *configArea, size_t configAreaBufferSize, size_t configSize, bool *swapNeeded, uint32_t *moduleStructSize)
{
	uint32_t *					arrayStart = NULL;
	uint32_t *					arrayEnd = NULL;

	uint32_t					kernelSegmentStart;
	uint32_t					lastTag;

	uint32_t *					ptr = NULL;
	uint32_t					ptrValue;
	struct _avm_kernel_config *	entry;

	bool						assumeSwapped = false;
	uint32_t					_moduleStructSize = 0;

	//	- a 32-bit value with more than one byte containing a non-zero value
	//	  should be a pointer in the config area
	//	- a value with only one non-zero byte is usually the tag, tags are
	//	  'enums' and have to be below or equal to avm_kernel_config_tags_last
	//	- values without any bit set are expected to be alignments or end of
	//	  array markers
	//	- we'll stop at the second 'end of array' marker, assuming we've
	//	  reached the end of 'struct _avm_kernel_config' array, the tag at
	//	  this array entry should be equal to avm_kernel_config_tags_last
	//	- limit search to the first 4 KB as DTB and the config area array
	//	  are located within the same 4 KB "segment"

	ptr = (uint32_t *) configArea;
	if (*ptr == 0) {
		// 1st 32-bit word is the pointer to the config area array
		// and is thus not allowed/expected to be NULL
		return false;
	}

	if ((configSize % (16 * 1024)) != 0) {
		// configSize is expected to be a multiple of 16K
		return false;
	}

	if (configSize > configAreaBufferSize) {
		// config area could not be bigger than the available buffer
		return false;
	}

	{
		int i;

		uint32_t *configAreaBeyondPtr = (uint32_t *) (((char *)configArea) + configSize);

		// heuristic:
		//   config area is known to be padded with zeros
		//   check last N 32-bit words are zeros
		for (i = 1; i <= 4; i++) {
			if ( *(configAreaBeyondPtr-i) != 0) {
				return false;
			}
		}

		if (configSize < configAreaBufferSize) {
			// and the first bytes right after the config area are not zeros
			if (*configAreaBeyondPtr == 0) {
				return false;
			}
		}
	}

	while (++ptr < ((uint32_t *) configArea) + (4096 / sizeof(uint32_t)))
	{
		if (*ptr != 0)
		{
			if (arrayStart == NULL) {
				arrayStart = ptr;  // 2nd non-zero word is the start of the config area array
			} /* else ... */       // all other non-zero words are the content of the config area array => ignore them
		}
		else
		{
			if (arrayStart != NULL) {
				// 1st zero word after arrayStart => this is the end of the config area array
				// or to be more precise zero word is the config-pointer of the entry with tag avm_kernel_config_tags_last
				arrayEnd = ptr + 1; // thus +1, arrayEnd is exclusive
				break;
			} /* else ... */        // zero words before arrayStart are alignment words
		}
	}

	// if we didn't find one of our pointers, something went wrong
	if (arrayStart == NULL || arrayEnd == NULL)
		return false;

	// check avm_kernel_config_tags_last entry first
	entry = (struct _avm_kernel_config *) arrayEnd - 1;
	lastTag = entry->tag;

	// guess if endianness swap is required
#ifdef USE_STRIPPED_AVM_KERNEL_CONFIG_H
	// stripped "avm_kernel_config.h" intentionally doesn't provide avm_kernel_config_tags_last symbol
	#define MAX_PLAUSIBLE_AVM_KERNEL_CONFIG_TAGS_ENUM (0x000001FF)
	assumeSwapped = (lastTag <= MAX_PLAUSIBLE_AVM_KERNEL_CONFIG_TAGS_ENUM ? false : true);
	swapEndianness(assumeSwapped, &lastTag);
	if (!(avm_kernel_config_tags_undef < lastTag && lastTag <= MAX_PLAUSIBLE_AVM_KERNEL_CONFIG_TAGS_ENUM))
		return false;
#else
	assumeSwapped = (lastTag <= avm_kernel_config_tags_last ? false : true);
	swapEndianness(assumeSwapped, &lastTag);
	if (lastTag != avm_kernel_config_tags_last)
		return false;
#endif

	// check other tags
	for (entry = (struct _avm_kernel_config *) arrayStart; entry->config != NULL; entry++)
	{
		uint32_t tag = entry->tag;
		swapEndianness(assumeSwapped, &tag);
		// invalid value means, our assumption was wrong
		if (!(avm_kernel_config_tags_undef < tag && tag <= lastTag)) /* that lastTag is in range has been validated before */
			return false;
	}

	// compute the start of the kernel "segment" config area is located within (target address space)
	ptrValue = *((uint32_t *)configArea);
	swapEndianness(assumeSwapped, &ptrValue);
	kernelSegmentStart = determineConfigAreaKernelSegment(ptrValue);

	// first value has to point to the array
	if (targetPtr2HostPtr(ptrValue, kernelSegmentStart, configArea) != arrayStart)
		return false;

	// check each entry->config pointer, if its value is in range
	for (entry = (struct _avm_kernel_config *) arrayStart; entry->config != NULL; entry++)
	{
		ptrValue = (uint32_t) entry->config;
		swapEndianness(assumeSwapped, &ptrValue);

		// check if it points to an address within kernel config area
		if (!(kernelSegmentStart <= ptrValue && ptrValue < (kernelSegmentStart+configSize)))
			return false;

		{
			uint32_t tag = entry->tag;
			swapEndianness(assumeSwapped, &tag);
			if (tag == avm_kernel_config_tags_modulememory)
			{
				uint32_t *module_0_ptr = targetPtr2HostPtr(ptrValue, kernelSegmentStart, configArea);

				uint32_t module_0 = *(module_0_ptr + 0);
				swapEndianness(assumeSwapped, &module_0);

				uint32_t module_2 = *(module_0_ptr + 2);
				swapEndianness(assumeSwapped, &module_2);

				uint32_t module_4 = *(module_0_ptr + 4);
				swapEndianness(assumeSwapped, &module_4);

				// we assume "modulememory array" contains at least 2 entries
				if ((module_0 & 0xFFFFF000) == (module_2 & 0xFFFFF000)) {
					_moduleStructSize = 2;
				} else if ((module_0 & 0xFFFFF000) == (module_4 & 0xFFFFF000)) {
					_moduleStructSize = 4;
				}
			}
		}
	}

	// we may be sure here that the endianness was detected successfully
	if (swapNeeded)
		*swapNeeded = assumeSwapped;

	if (moduleStructSize)
		*moduleStructSize = _moduleStructSize;

	return true;
}

struct _avm_kernel_config* * relocateConfigArea(void *configArea, size_t configSize, uint32_t *moduleStructSize)
{
	bool swapNeeded;
	uint32_t _moduleStructSize;
	uint32_t kernelSegmentStart;
	struct _avm_kernel_config * entry;

	//  - the configuration area is aligned on a 4K boundary and the first 32 bit contain a
	//    pointer to an 'struct _avm_kernel_config' array
	//  - we take the first 32 bit value from the dump and align this pointer to 4K to get
	//    the start address of the area in the linked kernel

	if (!isConsistentConfigArea(configArea, configSize, configSize, &swapNeeded, &_moduleStructSize))
		return NULL;

	swapEndianness(swapNeeded, (uint32_t *) configArea);
	kernelSegmentStart = determineConfigAreaKernelSegment(*((uint32_t *)configArea));

	entry = (struct _avm_kernel_config *) targetPtr2HostPtr(*((uint32_t *)configArea), kernelSegmentStart, configArea);
	*((struct _avm_kernel_config **)configArea) = entry;

	swapEndianness(swapNeeded, &entry->tag);

	while (entry->config != NULL)
	{
		swapEndianness(swapNeeded, (uint32_t *) &entry->config);
		entry->config = (void *) targetPtr2HostPtr((uint32_t)entry->config, kernelSegmentStart, configArea);

		if ((int) entry->tag == avm_kernel_config_tags_modulememory)
		{
			// only _kernel_modulmemory_config entries need relocation of members

			if (_moduleStructSize == 2) {
				struct _kernel_modulmemory_config2 * module = (struct _kernel_modulmemory_config2 *) entry->config;

				while (module->name != NULL)
				{
					swapEndianness(swapNeeded, (uint32_t *) &module->name);
					module->name = (char *) targetPtr2HostPtr((uint32_t)module->name, kernelSegmentStart, configArea);
					swapEndianness(swapNeeded, &module->size);

					module++;
				}
			} else if (_moduleStructSize == 4) {
				struct _kernel_modulmemory_config4 * module = (struct _kernel_modulmemory_config4 *) entry->config;

				while (module->name != NULL)
				{
					swapEndianness(swapNeeded, (uint32_t *) &module->name);
					module->name = (char *) targetPtr2HostPtr((uint32_t)module->name, kernelSegmentStart, configArea);
					swapEndianness(swapNeeded, &module->size);
					swapEndianness(swapNeeded, &module->symbol_size);
					swapEndianness(swapNeeded, &module->symbol_text_size);

					module++;
				}
			} else {
				fprintf(stderr, "Error: unknown _kernel_modulmemory_config size\n");
			}
		}

		entry++;
		swapEndianness(swapNeeded, &entry->tag);
	}

	if (moduleStructSize)
		*moduleStructSize = _moduleStructSize;

	return (struct _avm_kernel_config **)configArea;
}

uint32_t determineConfigAreaKernelSegment(uint32_t targetAddressSpacePtr)
{
	return (targetAddressSpacePtr & 0xFFFFF000);
}

void* targetPtr2HostPtr(uint32_t targetAddressSpacePtr, uint32_t targetAddressSpaceBasePtr, void* hostAddressSpaceBasePtr)
{
	if (!(targetAddressSpaceBasePtr <= targetAddressSpacePtr)) {
		fprintf(stderr, "Warning: targetAddressSpaceBasePtr(0x%08x) <= targetAddressSpacePtr(0x%08x) violated, doing no conversion\n", targetAddressSpaceBasePtr, targetAddressSpacePtr);
		return (void*)targetAddressSpacePtr;
	}

	return (void*) ((char *)hostAddressSpaceBasePtr + (targetAddressSpacePtr - targetAddressSpaceBasePtr));
}

struct _avm_kernel_config* findEntryByTag(struct _avm_kernel_config * *configArea, enum _avm_kernel_config_tags tag)
{
	if (*configArea == NULL)
		return NULL;

	for (struct _avm_kernel_config * entry = *configArea; entry->config != NULL; entry++)
	{
		if (entry->tag == tag)
			return entry;
	}

	return NULL;
}

bool isDeviceTreeEntry(struct _avm_kernel_config* entry)
{
	if (entry == NULL || entry->config == NULL)
		return false;

	// entry->config is assumed to be already relocated
	return (fdt_magic(entry->config) == FDT_MAGIC) && (fdt_check_header(entry->config) == 0);
}
