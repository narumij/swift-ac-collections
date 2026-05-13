#include "FastIO.h"

int buffer[39] = {0};

static inline void ___print_positive(uint64_t x) {
  int i = 0;
  do {
    int r = x % 10;
    x = x / 10;
    buffer[i] = 0x30 | r;
    i += 1;
  } while (x > 0);
  while (i > 0) {
    i -= 1;
    putchar_unlocked(buffer[i]);
  }
}

static inline void ___print_negative(int64_t x) {
  putchar_unlocked(0x2D);
  int i = 0;
  do {
    int r = x % 10;
    x = x / 10;
    buffer[i] = 0x30 | -r;
    ++i;
  } while (x < 0);
  while (i > 0) {
    --i;
    putchar_unlocked(buffer[i]);
  }
}

void ___print_int(int64_t x) {
  if (x < 0) {
    ___print_negative(x);
  }
  else {
    ___print_positive(x);
  }
}

void ___print_uint(uint64_t x) {
    ___print_positive(x);
}
