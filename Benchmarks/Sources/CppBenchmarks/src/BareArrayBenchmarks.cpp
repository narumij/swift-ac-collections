#include <cstdint>
#include <vector>

#include "BareArrayBenchmarks.h"

using NestedVector2D = std::vector<std::vector<intptr_t>>;
using NestedVector3D = std::vector<std::vector<std::vector<intptr_t>>>;

void *
cpp_vector_1d_create(size_t count)
{
  auto *array = new std::vector<intptr_t>(count);
  intptr_t value = 0;
  for (auto &element : *array) {
    element = value++;
  }
  return array;
}

void *
cpp_nested_vector_2d_create(size_t width, size_t height)
{
  auto *array = new NestedVector2D(height, std::vector<intptr_t>(width));
  intptr_t value = 0;
  for (auto &row : *array) {
    for (auto &element : row) {
      element = value++;
    }
  }
  return array;
}

void *
cpp_nested_vector_3d_create(size_t width, size_t height, size_t depth)
{
  auto *array = new NestedVector3D(
    depth,
    std::vector<std::vector<intptr_t>>(
      height,
      std::vector<intptr_t>(width)));
  intptr_t value = 0;
  for (auto &plane : *array) {
    for (auto &row : plane) {
      for (auto &element : row) {
        element = value++;
      }
    }
  }
  return array;
}

void
cpp_nested_vector_2d_destroy(void *ptr)
{
  delete static_cast<NestedVector2D *>(ptr);
}

void
cpp_vector_1d_destroy(void *ptr)
{
  delete static_cast<std::vector<intptr_t> *>(ptr);
}

void
cpp_nested_vector_3d_destroy(void *ptr)
{
  delete static_cast<NestedVector3D *>(ptr);
}

intptr_t
cpp_nested_vector_2d_checksum(void *ptr)
{
  const auto *array = static_cast<NestedVector2D *>(ptr);
  intptr_t checksum = 0;
  for (const auto &row : *array) {
    for (const auto element : row) {
      checksum += element;
    }
  }
  return checksum;
}

intptr_t
cpp_vector_1d_checksum(void *ptr)
{
  const auto *array = static_cast<std::vector<intptr_t> *>(ptr);
  intptr_t checksum = 0;
  for (const auto element : *array) {
    checksum += element;
  }
  return checksum;
}

intptr_t
cpp_nested_vector_3d_checksum(void *ptr)
{
  const auto *array = static_cast<NestedVector3D *>(ptr);
  intptr_t checksum = 0;
  for (const auto &plane : *array) {
    for (const auto &row : plane) {
      for (const auto element : row) {
        checksum += element;
      }
    }
  }
  return checksum;
}

void
cpp_nested_vector_2d_write(void *ptr)
{
  auto *array = static_cast<NestedVector2D *>(ptr);
  intptr_t value = 0;
  for (auto &row : *array) {
    for (auto &element : row) {
      element = value++;
    }
  }
}

void
cpp_vector_1d_write(void *ptr)
{
  auto *array = static_cast<std::vector<intptr_t> *>(ptr);
  intptr_t value = 0;
  for (auto &element : *array) {
    element = value++;
  }
}

void
cpp_nested_vector_3d_write(void *ptr)
{
  auto *array = static_cast<NestedVector3D *>(ptr);
  intptr_t value = 0;
  for (auto &plane : *array) {
    for (auto &row : plane) {
      for (auto &element : row) {
        element = value++;
      }
    }
  }
}
