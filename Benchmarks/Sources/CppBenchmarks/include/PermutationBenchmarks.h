#ifndef CPPBENCHMARKS_PERMUTATION_BENCHMARKS_H
#define CPPBENCHMARKS_PERMUTATION_BENCHMARKS_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Creates the ascending integer source used by the permutation benchmark.
extern void *cpp_permutation_create(size_t count);

/// Creates an ascending binary source with `selected_count` trailing ones.
extern void *cpp_permutation_create_binary(
  size_t count,
  size_t selected_count);

/// Destroys a source previously returned by `cpp_permutation_create`.
extern void cpp_permutation_destroy(void *ptr);

/// Copies the source, enumerates it with `std::next_permutation`, and returns
/// the permutation count and position-weighted checksum.
extern void cpp_permutation_end_to_end(
  void *ptr,
  intptr_t *permutation_count,
  intptr_t *checksum);

#ifdef __cplusplus
}
#endif

#endif /* CPPBENCHMARKS_PERMUTATION_BENCHMARKS_H */
