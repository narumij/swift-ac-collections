#pragma once
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef struct mt19937_64_impl mt19937_64_impl;

typedef struct mt19937_64 {
  mt19937_64_impl* handle;
} mt19937_64;

mt19937_64* mt19937_64_create(uint32_t seed);
void     mt19937_64_destroy(mt19937_64*);
uint64_t mt19937_64_next_u64(mt19937_64*);
void     mt19937_64_discard(mt19937_64*, uint64_t);

#ifdef __cplusplus
}
#endif
