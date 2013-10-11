#include <stdio.h>
#include <stdarg.h>
#include <wchar.h>
#include <locale.h>

void WriteWideFormatted (FILE * stream, const wchar_t * format, ...)
{
  va_list args;
  va_start (args, format);
  vfwprintf (stream, format, args);
  va_end (args);
}

int main ()
{
   setlocale(LC_ALL,"");

   WriteWideFormatted (stderr,L"Call with %d variable argument.\n",1);
   WriteWideFormatted (stderr,L"Call with %d variable %ls.\n",2,L"arguments");

   return 0;
}
