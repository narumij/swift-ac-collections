#ifndef FastPrint_h
#define FastPrint_h

#include <stdio.h>
#include <stdint.h>

void ___print_int(int64_t x);
void ___print_uint(uint64_t x);

size_t _readLine_stdin(unsigned char **LinePtr);
void _free(void * ptr);

#endif /* FastPrint_h */
