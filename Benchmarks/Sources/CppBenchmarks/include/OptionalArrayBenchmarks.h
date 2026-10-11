#ifndef CPPBENCHMARKS_OPTIONAL_ARRAY_BENCHMARKS_H
#define CPPBENCHMARKS_OPTIONAL_ARRAY_BENCHMARKS_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void *cpp_sentinel_vector_2d_create(size_t width, size_t height);
extern void *cpp_sentinel_vector_3d_create(
  size_t width,
  size_t height,
  size_t depth);
extern void cpp_sentinel_vector_2d_destroy(void *ptr);
extern void cpp_sentinel_vector_3d_destroy(void *ptr);
extern void cpp_sentinel_vector_2d_reset(void *ptr);
extern void cpp_sentinel_vector_3d_reset(void *ptr);
extern void cpp_sentinel_vector_2d_prepare_warm(void *ptr);
extern void cpp_sentinel_vector_3d_prepare_warm(void *ptr);
extern intptr_t cpp_sentinel_vector_2d_memoization_checksum(void *ptr);
extern intptr_t cpp_sentinel_vector_3d_memoization_checksum(void *ptr);

#ifdef __cplusplus
}
#endif

#endif /* CPPBENCHMARKS_OPTIONAL_ARRAY_BENCHMARKS_H */
