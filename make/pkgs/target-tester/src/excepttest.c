#include <cstdio>
#include <cstring>
#include <exception>
#include <stdexcept>

static const char exceptionNotThrown[] = "Exception not thrown (***BAD***)\n";

int main(int argc, char **argv) {
	printf("Starting exception testing\n");

	try {
		printf("Throwing out of range\n");
		throw std::out_of_range("This is text");
		printf(exceptionNotThrown);
	} catch (std::out_of_range &e) {
		if (strcmp(e.what(), "This is text") == 0) {
			printf("Caught thrown exception\n");
		} else {
			printf("Caught exception with different exception text\n");
			printf("Exception text: %s\n", e.what() );
		}
	} catch (...) {
		printf("Missed catching exception (***BAD***)\n");
	}

	printf("Testing inheriting exception handler\n");
	try {
		printf("Throwing length_error\n");
		throw std::length_error("Length error test text");
		printf(exceptionNotThrown);
	} catch (std::out_of_range &e) {
		printf("Caught out_of_range (***BAD***)\n");
	} catch (std::logic_error &e) {
		printf("Caught logic_error (good)\n");
	} catch (...) {
		printf("Caught generic exception (***BAD***)\n");
	}

	printf("Testing generic exception handler\n");
	try {
		printf("Throwing length_error\n");
		throw std::length_error("Length error test text");
		printf(exceptionNotThrown);
	} catch (std::out_of_range &e) {
		printf("Caught out_of_range (***BAD***)\n");
	} catch (...) {
		printf("Caught generic exception (good)\n");
	}

	printf("Testing primitive type exception handling\n");
	try {
		printf("Throwing 42\n");
		throw 42;
		printf(exceptionNotThrown);
	} catch (int i) {
		if (i == 42)
			printf("Caught 42 (good)\n");
		else
			printf("Caught %d (***BAD***)\n", i);
	} catch (...) {
			printf("Caught generic exception (***BAD***)\n");
	}

	return 0;
}
