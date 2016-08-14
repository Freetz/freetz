#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>

#ifndef FALSE
#define FALSE (0)
#endif

#ifndef TRUE
#define TRUE (1)
#endif

//#define DO_DEBUG
#ifdef DO_DEBUG
#define DBG(...) fprintf(stderr, __VA_ARGS__)
#else
#define DBG(...)
#endif

size_t i_offset = 0;
size_t o_offset = 0;

int readByte(uint8_t *byte, int failOnEOF) {
	int c = getchar();

	if (failOnEOF && c == EOF) {
		fprintf(stderr, "Unexpected end of AVM-RLE stream\n");
		exit(EXIT_FAILURE);
	}
	i_offset++;
	if (byte) {
		*byte = c;
	}
	return (c == EOF);
}

size_t readLen(size_t lenWidthInBytes) {
	size_t ret = 0, i;
	uint8_t b;

	for (i=0; i<lenWidthInBytes; i++) {
		readByte(&b, TRUE);
		ret += (b << (8*i)); // this assumes len is LE encoded
	}

	return ret;
}

void writeBytes(uint8_t byteToWrite, size_t len) {
	DBG("Writing 0x%02X %zu time%s\n", byteToWrite, len, (len!=1) ? "s" : "");
	for (; len>0; len--) {
		putchar(byteToWrite);
		o_offset++;
	}
}

int main(int argc, char * argv[]) {
	uint8_t opcode, payload;
	size_t  payloadLen, bytesToSkip, i;

	bytesToSkip = (argc >= 2) ? strtoul(argv[1], NULL, 16) : 0;
	for (i=0; i<bytesToSkip; i++) {
		if (readByte(NULL, FALSE)) {
			fprintf(stderr, "End of stream reached before RLE decoding could be started\n");
			return EXIT_FAILURE;
		}
	}

	while (!readByte(&opcode, FALSE)) {
		DBG("Processing opcode 0x%02X at offset %zu\n", opcode, i_offset);

		if (opcode == 0x00) {
			payloadLen = readLen(1);
			if (payloadLen == 0) {
				// end of compressed content before end of stream
				break;
			}
			payload = 0x00;
			writeBytes(payload, payloadLen);
		} else if (opcode <= 0x7F) {
			// copy opcode-many bytes to output
			for (i=0; i<opcode; i++) {
				readByte(&payload, TRUE);
				writeBytes(payload, 1);
			}
		} else if (opcode == 0x80 || opcode == 0x81) {
			payloadLen = readLen(opcode - 0x7F); // len is encoded in the next byte for 0x80, and in the next 2 bytes for 0x81
			readByte(&payload, TRUE);
			writeBytes(payload, payloadLen);
		} else if (opcode == 0x82) {
			payloadLen = readLen(1);
			payload = 0x20;
			writeBytes(payload, payloadLen);
		} else /* if (0x82 < opcode && opcode <= 0xFF) */ {
			payloadLen = (opcode - 0x80);
			readByte(&payload, TRUE);
			writeBytes(payload, payloadLen);
		}
	}

	return EXIT_SUCCESS;
}
