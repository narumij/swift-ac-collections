#include "CppBehaviorReference.h"

#include <algorithm>
#include <iterator>
#include <set>

int32_t cpp_set_execute_trace(
    const CppSetOperation *operations,
    size_t operation_count,
    CppSetObservation *observations,
    size_t observation_capacity,
    int64_t *contents,
    size_t contents_capacity) {
  if (observation_capacity < operation_count) {
    return CPP_SET_TRACE_INSUFFICIENT_OBSERVATIONS;
  }

  std::set<int64_t> set;
  size_t contents_offset = 0;

  for (size_t operation_index = 0; operation_index < operation_count;
       ++operation_index) {
    const auto operation = operations[operation_index];
    CppSetObservation observation = {};
    observation.kind = operation.kind;
    observation.argument = operation.value;

    switch (operation.kind) {
    case CPP_SET_OPERATION_INSERT: {
      const auto result = set.insert(operation.value);
      observation.boolean_result = result.second;
      observation.has_value = true;
      observation.value = *result.first;
      break;
    }
    case CPP_SET_OPERATION_LOWER_BOUND: {
      const auto result = set.lower_bound(operation.value);
      observation.has_value = result != set.end();
      if (observation.has_value) {
        observation.value = *result;
      }
      break;
    }
    case CPP_SET_OPERATION_ERASE_KEY:
      observation.boolean_result = set.erase(operation.value) != 0;
      break;
    case CPP_SET_OPERATION_INSERT_HINT: {
      if (operation.position < 0 ||
          static_cast<size_t>(operation.position) > set.size()) {
        return CPP_SET_TRACE_INVALID_POSITION;
      }
      auto hint = set.cbegin();
      std::advance(hint, operation.position);
      const auto previous_size = set.size();
      const auto result = set.insert(hint, operation.value);
      observation.boolean_result = set.size() != previous_size;
      observation.has_value = true;
      observation.value = *result;
      break;
    }
    default:
      return CPP_SET_TRACE_UNKNOWN_OPERATION;
    }

    if (contents_capacity - contents_offset < set.size()) {
      return CPP_SET_TRACE_INSUFFICIENT_CONTENTS;
    }

    observation.contents_offset = contents_offset;
    observation.contents_count = set.size();
    std::copy(set.begin(), set.end(), contents + contents_offset);
    contents_offset += set.size();
    observations[operation_index] = observation;
  }

  return CPP_SET_TRACE_SUCCESS;
}

int32_t cpp_multiset_execute_trace(
    const CppMultiSetOperation *operations,
    size_t operation_count,
    CppMultiSetObservation *observations,
    size_t observation_capacity,
    int64_t *contents,
    size_t contents_capacity) {
  if (observation_capacity < operation_count) {
    return CPP_MULTISET_TRACE_INSUFFICIENT_OBSERVATIONS;
  }

  std::multiset<int64_t> set;
  size_t contents_offset = 0;

  const auto rank_of = [&set](std::multiset<int64_t>::const_iterator it) {
    return static_cast<int64_t>(std::distance(set.cbegin(), it));
  };

  for (size_t operation_index = 0; operation_index < operation_count;
       ++operation_index) {
    const auto operation = operations[operation_index];
    CppMultiSetObservation observation = {};
    observation.kind = operation.kind;
    observation.argument = operation.value;
    observation.rank = -1;
    observation.erased_count = -1;
    observation.range_offset = contents_offset;

    switch (operation.kind) {
    case CPP_MULTISET_OPERATION_INSERT: {
      const auto result = set.insert(operation.value);
      observation.has_value = true;
      observation.value = *result;
      break;
    }
    case CPP_MULTISET_OPERATION_INSERT_HINT: {
      if (operation.position < 0 ||
          static_cast<size_t>(operation.position) > set.size()) {
        return CPP_MULTISET_TRACE_INVALID_POSITION;
      }
      auto hint = set.cbegin();
      std::advance(hint, operation.position);
      const auto result = set.insert(hint, operation.value);
      observation.has_value = true;
      observation.value = *result;
      observation.rank = rank_of(result);
      break;
    }
    case CPP_MULTISET_OPERATION_LOWER_BOUND:
    case CPP_MULTISET_OPERATION_UPPER_BOUND: {
      const auto result = operation.kind == CPP_MULTISET_OPERATION_LOWER_BOUND
                              ? set.lower_bound(operation.value)
                              : set.upper_bound(operation.value);
      observation.has_value = result != set.end();
      if (observation.has_value) {
        observation.value = *result;
      }
      observation.rank = rank_of(result);
      break;
    }
    case CPP_MULTISET_OPERATION_EQUAL_RANGE: {
      const auto range = set.equal_range(operation.value);
      const auto count =
          static_cast<size_t>(std::distance(range.first, range.second));
      if (contents_capacity - contents_offset < count) {
        return CPP_MULTISET_TRACE_INSUFFICIENT_CONTENTS;
      }
      std::copy(range.first, range.second, contents + contents_offset);
      observation.range_count = count;
      contents_offset += count;
      break;
    }
    case CPP_MULTISET_OPERATION_ERASE_KEY:
      observation.erased_count =
          static_cast<int64_t>(set.erase(operation.value));
      break;
    default:
      return CPP_MULTISET_TRACE_UNKNOWN_OPERATION;
    }

    if (contents_capacity - contents_offset < set.size()) {
      return CPP_MULTISET_TRACE_INSUFFICIENT_CONTENTS;
    }

    observation.contents_offset = contents_offset;
    observation.contents_count = set.size();
    std::copy(set.begin(), set.end(), contents + contents_offset);
    contents_offset += set.size();
    observations[operation_index] = observation;
  }

  return CPP_MULTISET_TRACE_SUCCESS;
}
