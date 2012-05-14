#include <stdio.h>
#define is32(n,t) for(n=1,k=0;n;n<<=1,k++);if(k==32){puts(t);return 0;}
int main() {
    int k;
    unsigned i;
    unsigned long l;
    unsigned short s;
    is32(i, "unsigned")
    is32(l, "unsigned long")
    is32(s, "unsigned short")
    return 1;
}
