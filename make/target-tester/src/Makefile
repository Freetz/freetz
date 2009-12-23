TARGET=target-tester
PREREQUISITE=target-tester

all: $(TARGET)

$(TARGET): $(TARGET).o
	$(CC) -o $@ $^

$(TARGET).o: $(PREREQUISITE).c
	$(CC) -c -o $@ $^ $(CFLAGS)

define AC_FUNC_TEST
@for ac_func in $1; do \
	rm -f $$ac_func.c $$ac_func; \
	./ac_func-test-generator.sh $$ac_func > $$ac_func.c \
	&& $(CC) -o $$ac_func $$ac_func.c $(CFLAGS) $2 $(LDFLAGS) >/dev/null 2>&1; \
	[ -x $$ac_func ] \
	&& echo "ac_cv_func_$$ac_func=yes" \
	|| echo "ac_cv_func_$$ac_func=no"; \
	rm -f $$ac_func.c $$ac_func; \
done
endef

math-functions: ac_func-test-generator.sh
	@echo using libc only
	$(call AC_FUNC_TEST, isnan isinf finite)
	@echo using libm
	$(call AC_FUNC_TEST, \
		isnan isinf finite \
		exp2l log2l exp10l log10l \
		sinl cosl tanl asinl acosl atanl atan2l \
		powl sqrtl rintl expl logl \
		remainderl fmodl roundl truncl floorl ceill \
		exp2 log2 exp10 log10 \
		sin cos tan asin acos atan atan2 \
		pow rint exp log \
		remainder fmod round trunc floor ceil, \
		-lm \
	)

clean:
	$(RM) $(TARGET) $(TARGET).o
