#!/bin/sh

[ -z "$1" ] && exit 1

ac_func="$1"

cat << EOF
/* Define $ac_func to an innocuous variant, in case <limits.h> declares $ac_func.
   For example, HP-UX 11i <limits.h> declares gettimeofday.  */
#define $ac_func innocuous_$ac_func

/* System header to define __stub macros and hopefully few prototypes,
   which can conflict with char $ac_func(); below.
   Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
   <limits.h> exists even on freestanding compilers.  */

#ifdef __STDC__
    #include <limits.h>
#else
    #include <assert.h>
#endif

#undef $ac_func

/* Override any GCC internal prototype to avoid an error.
   Use char because int might match the return type of a GCC
   builtin and then its argument prototype would still apply.  */

#ifdef __cplusplus
  extern "C"
#endif
char $ac_func();
/* The GNU C library defines this for functions which it implements
   to always fail with ENOSYS.  Some functions are actually named
   something starting with __ and the normal name is an alias.  */

#if defined __stub_$ac_func || defined __stub___$ac_func
 choke me
#endif

int main(int argc, char** argv) {
    return $ac_func();
}
EOF
