.menu .deco .cshrc .login *.c *.h *.cpp *.C
	vi %f

*.b
	rm %f

Makefile makefile *.mk
	make -f %f

core
	adb

*.o
	nm %f | more

*.a
	ar tv %f | more

*.tar
	tar -tvf %f | more

*.tar.gz *.tgz
	gzip -d -c %f | tar -tvf - | more
