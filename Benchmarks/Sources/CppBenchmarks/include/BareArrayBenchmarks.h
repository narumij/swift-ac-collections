#ifndef CPPBENCHMARKS_BARE_ARRAY_BENCHMARKS_H
#define CPPBENCHMARKS_BARE_ARRAY_BENCHMARKS_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void *cpp_nested_vector_2d_create(size_t width, size_t height);
extern void *cpp_nested_vector_3d_create(
  size_t width,
  size_t height,
  size_t depth);
extern void cpp_nested_vector_2d_destroy(void *ptr);
extern void cpp_nested_vector_3d_destroy(void *ptr);
extern intptr_t cpp_nested_vector_2d_checksum(void *ptr);
extern intptr_t cpp_nested_vector_3d_checksum(void *ptr);
extern void cpp_nested_vector_2d_write(void *ptr);
extern void cpp_nested_vector_3d_write(void *ptr);

#ifdef __cplusplus
}
#endif

#endif /* CPPBENCHMARKS_BARE_ARRAY_BENCHMARKS_H */
