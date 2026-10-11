#include <algorithm>
#include <cstdint>
#include <vector>

#include "OptionalArrayBenchmarks.h"

using SentinelVector2D = std::vector<std::vector<intptr_t>>;
using SentinelVector3D = std::vector<std::vector<std::vector<intptr_t>>>;

static constexpr intptr_t sentinel = -1;

void *
cpp_sentinel_vector_2d_create(size_t width, size_t height)
{
  return new SentinelVector2D(height, std::vector<intptr_t>(width, sentinel));
}

void *
cpp_sentinel_vector_3d_create(size_t width, size_t height, size_t depth)
{
  return new SentinelVector3D(
    depth,
    std::vector<std::vector<intptr_t>>(
      height,
      std::vector<intptr_t>(width, sentinel)));
}

void
cpp_sentinel_vector_2d_destroy(void *ptr)
{
  delete static_cast<SentinelVector2D *>(ptr);
}

void
cpp_sentinel_vector_3d_destroy(void *ptr)
{
  delete static_cast<SentinelVector3D *>(ptr);
}

void
cpp_sentinel_vector_2d_reset(void *ptr)
{
  auto *array = static_cast<SentinelVector2D *>(ptr);
  for (auto &row : *array) {
    std::fill(row.begin(), row.end(), sentinel);
  }
}

void
cpp_sentinel_vector_3d_reset(void *ptr)
{
  auto *array = static_cast<SentinelVector3D *>(ptr);
  for (auto &plane : *array) {
    for (auto &row : plane) {
      std::fill(row.begin(), row.end(), sentinel);
    }
  }
}

void
cpp_sentinel_vector_2d_prepare_warm(void *ptr)
{
  auto *array = static_cast<SentinelVector2D *>(ptr);
  intptr_t value = 0;
  for (auto &row : *array) {
    for (auto &element : row) {
      element = value++;
    }
  }
}

void
cpp_sentinel_vector_3d_prepare_warm(void *ptr)
{
  auto *array = static_cast<SentinelVector3D *>(ptr);
  intptr_t value = 0;
  for (auto &plane : *array) {
    for (auto &row : plane) {
      for (auto &element : row) {
        element = value++;
      }
    }
  }
}

intptr_t
cpp_sentinel_vector_2d_memoization_checksum(void *ptr)
{
  auto *array = static_cast<SentinelVector2D *>(ptr);
  intptr_t value = 0;
  intptr_t checksum = 0;
  for (auto &row : *array) {
    for (auto &element : row) {
      if (element == sentinel) {
        element = value;
      }
      checksum += element;
      ++value;
    }
  }
  return checksum;
}

intptr_t
cpp_sentinel_vector_3d_memoization_checksum(void *ptr)
{
  auto *array = static_cast<SentinelVector3D *>(ptr);
  intptr_t value = 0;
  intptr_t checksum = 0;
  for (auto &plane : *array) {
    for (auto &row : plane) {
      for (auto &element : row) {
        if (element == sentinel) {
          element = value;
        }
        checksum += element;
        ++value;
      }
    }
  }
  return checksum;
}
