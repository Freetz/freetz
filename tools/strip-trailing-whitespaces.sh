#!/bin/sh

find . \
	-type f \
	\( \
		-name "Config.in" \
		-o -name "Config.in.avm" \
		-o -name "Config.in.kernel" \
		-o -name "Config.in.modules" \
		-o -name "Config.in.override" \
		-o -name "Config.in.libs" \
		-o -name "external.files" \
		-o -name "external.in" \
		-o -name "external.in.libs" \
		-o -name "external.services" \
		-o -name "*.mk" \
		-o -name "*.mk.in" \
		-o -name ".language" \
		-o -name "README" \
		-o -name "*.def" \
		-o -name "*.cfg" \
		-o -name "*.inetd" \
		-o -name "*_conf" \
		-o -name "rc.*" \
		-o -name "*.cgi" \
		-o -name "*.sh" \
	\) \
	-exec sed -r -i -e 's,([ \t])+$,,' \{\} +
