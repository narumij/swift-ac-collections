#include <algorithm>
#include <cstdint>
#include <numeric>
#include <vector>

#include "PermutationBenchmarks.h"

void *
cpp_permutation_create(size_t count)
{
  auto source = new std::vector<intptr_t>(count);
  std::iota(source->begin(), source->end(), 0);
  return source;
}

void *
cpp_permutation_create_binary(size_t count, size_t selected_count)
{
  auto source = new std::vector<intptr_t>(count, 0);
  std::fill(source->end() - selected_count, source->end(), 1);
  return source;
}

void
cpp_permutation_destroy(void *ptr)
{
  delete static_cast<std::vector<intptr_t> *>(ptr);
}

void
cpp_permutation_end_to_end(
  void *ptr,
  intptr_t *permutation_count,
  intptr_t *checksum)
{
  const auto *source = static_cast<std::vector<intptr_t> *>(ptr);
  auto permutation = *source;
  intptr_t count = 0;
  intptr_t sum = 0;

  do {
    for (size_t i = 0; i < permutation.size(); ++i) {
      sum += permutation[i] * static_cast<intptr_t>(i + 1);
    }
    ++count;
  } while (std::next_permutation(permutation.begin(), permutation.end()));

  *permutation_count = count;
  *checksum = sum;
}
