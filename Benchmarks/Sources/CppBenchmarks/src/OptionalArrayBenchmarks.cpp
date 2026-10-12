#include <algorithm>
#include <cstdint>
#include <optional>
#include <vector>

#include "OptionalArrayBenchmarks.h"

using SentinelVector1D = std::vector<intptr_t>;
using SentinelVector2D = std::vector<std::vector<intptr_t>>;
using SentinelVector3D = std::vector<std::vector<std::vector<intptr_t>>>;
using OptionalVector1D = std::vector<std::optional<intptr_t>>;
using OptionalVector2D = std::vector<std::vector<std::optional<intptr_t>>>;
using OptionalVector3D =
  std::vector<std::vector<std::vector<std::optional<intptr_t>>>>;

static constexpr intptr_t sentinel = -1;

void *
cpp_sentinel_vector_1d_create(size_t count)
{
  return new SentinelVector1D(count, sentinel);
}

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
cpp_sentinel_vector_1d_destroy(void *ptr)
{
  delete static_cast<SentinelVector1D *>(ptr);
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
cpp_sentinel_vector_1d_reset(void *ptr)
{
  auto *array = static_cast<SentinelVector1D *>(ptr);
  std::fill(array->begin(), array->end(), sentinel);
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
cpp_sentinel_vector_1d_prepare_warm(void *ptr)
{
  auto *array = static_cast<SentinelVector1D *>(ptr);
  intptr_t value = 0;
  for (auto &element : *array) {
    element = value++;
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
cpp_sentinel_vector_1d_memoization_checksum(void *ptr)
{
  auto *array = static_cast<SentinelVector1D *>(ptr);
  intptr_t value = 0;
  intptr_t checksum = 0;
  for (auto &element : *array) {
    if (element == sentinel) {
      element = value;
    }
    checksum += element;
    ++value;
  }
  return checksum;
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

void *
cpp_optional_vector_1d_create(size_t count)
{
  return new OptionalVector1D(count);
}

void *
cpp_optional_vector_2d_create(size_t width, size_t height)
{
  return new OptionalVector2D(
    height,
    std::vector<std::optional<intptr_t>>(width));
}

void *
cpp_optional_vector_3d_create(size_t width, size_t height, size_t depth)
{
  return new OptionalVector3D(
    depth,
    std::vector<std::vector<std::optional<intptr_t>>>(
      height,
      std::vector<std::optional<intptr_t>>(width)));
}

void
cpp_optional_vector_1d_destroy(void *ptr)
{
  delete static_cast<OptionalVector1D *>(ptr);
}

void
cpp_optional_vector_2d_destroy(void *ptr)
{
  delete static_cast<OptionalVector2D *>(ptr);
}

void
cpp_optional_vector_3d_destroy(void *ptr)
{
  delete static_cast<OptionalVector3D *>(ptr);
}

void
cpp_optional_vector_1d_reset(void *ptr)
{
  auto *array = static_cast<OptionalVector1D *>(ptr);
  std::fill(array->begin(), array->end(), std::nullopt);
}

void
cpp_optional_vector_2d_reset(void *ptr)
{
  auto *array = static_cast<OptionalVector2D *>(ptr);
  for (auto &row : *array) {
    std::fill(row.begin(), row.end(), std::nullopt);
  }
}

void
cpp_optional_vector_3d_reset(void *ptr)
{
  auto *array = static_cast<OptionalVector3D *>(ptr);
  for (auto &plane : *array) {
    for (auto &row : plane) {
      std::fill(row.begin(), row.end(), std::nullopt);
    }
  }
}

void
cpp_optional_vector_1d_prepare_warm(void *ptr)
{
  auto *array = static_cast<OptionalVector1D *>(ptr);
  intptr_t value = 0;
  for (auto &element : *array) {
    element = value++;
  }
}

void
cpp_optional_vector_2d_prepare_warm(void *ptr)
{
  auto *array = static_cast<OptionalVector2D *>(ptr);
  intptr_t value = 0;
  for (auto &row : *array) {
    for (auto &element : row) {
      element = value++;
    }
  }
}

void
cpp_optional_vector_3d_prepare_warm(void *ptr)
{
  auto *array = static_cast<OptionalVector3D *>(ptr);
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
cpp_optional_vector_1d_memoization_checksum(void *ptr)
{
  auto *array = static_cast<OptionalVector1D *>(ptr);
  intptr_t value = 0;
  intptr_t checksum = 0;
  for (auto &element : *array) {
    if (!element) {
      element = value;
    }
    checksum += *element;
    ++value;
  }
  return checksum;
}

intptr_t
cpp_optional_vector_2d_memoization_checksum(void *ptr)
{
  auto *array = static_cast<OptionalVector2D *>(ptr);
  intptr_t value = 0;
  intptr_t checksum = 0;
  for (auto &row : *array) {
    for (auto &element : row) {
      if (!element) {
        element = value;
      }
      checksum += *element;
      ++value;
    }
  }
  return checksum;
}

intptr_t
cpp_optional_vector_3d_memoization_checksum(void *ptr)
{
  auto *array = static_cast<OptionalVector3D *>(ptr);
  intptr_t value = 0;
  intptr_t checksum = 0;
  for (auto &plane : *array) {
    for (auto &row : plane) {
      for (auto &element : row) {
        if (!element) {
          element = value;
        }
        checksum += *element;
        ++value;
      }
    }
  }
  return checksum;
}
