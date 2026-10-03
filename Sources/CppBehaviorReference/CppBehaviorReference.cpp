#include "CppBehaviorReference.h"

#include <algorithm>
#include <iterator>
#include <map>
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
    observation.count = -1;

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
    case CPP_SET_OPERATION_UPPER_BOUND: {
      const auto result = set.upper_bound(operation.value);
      observation.has_value = result != set.end();
      if (observation.has_value) {
        observation.value = *result;
      }
      break;
    }
    case CPP_SET_OPERATION_FIND:
      observation.boolean_result = set.find(operation.value) != set.end();
      observation.count = static_cast<int64_t>(set.count(operation.value));
      break;
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
    observation.count = -1;
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
    case CPP_MULTISET_OPERATION_FIND:
      observation.found = set.find(operation.value) != set.end();
      observation.count = static_cast<int64_t>(set.count(operation.value));
      break;
    case CPP_MULTISET_OPERATION_ERASE_KEY:
      observation.erased_count =
          static_cast<int64_t>(set.erase(operation.value));
      break;
    case CPP_MULTISET_OPERATION_ERASE_AT:
    case CPP_MULTISET_OPERATION_REMOVE_AT: {
      // Positional erasure needs an element, not `end()`.
      if (operation.position < 0 ||
          static_cast<size_t>(operation.position) >= set.size()) {
        return CPP_MULTISET_TRACE_INVALID_POSITION;
      }
      auto position = set.cbegin();
      std::advance(position, operation.position);
      if (operation.kind == CPP_MULTISET_OPERATION_ERASE_AT) {
        observation.rank = rank_of(set.erase(position));
      } else {
        observation.has_value = true;
        observation.value = *position;
        set.erase(position);
      }
      break;
    }
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

int32_t cpp_map_execute_trace(
    const CppMapOperation *operations,
    size_t operation_count,
    CppMapObservation *observations,
    size_t observation_capacity,
    CppMapEntry *contents,
    size_t contents_capacity) {
  if (observation_capacity < operation_count) {
    return CPP_MAP_TRACE_INSUFFICIENT_OBSERVATIONS;
  }

  using Map = std::map<int64_t, int64_t>;
  Map map;
  size_t contents_offset = 0;

  const auto rank_of = [&map](Map::const_iterator it) {
    return static_cast<int64_t>(std::distance(map.cbegin(), it));
  };
  const auto entry_of = [](Map::const_iterator it) {
    return CppMapEntry{it->first, it->second};
  };
  const auto copy_entries = [&](Map::const_iterator first,
                                Map::const_iterator last) {
    for (; first != last; ++first) {
      contents[contents_offset++] = CppMapEntry{first->first, first->second};
    }
  };

  for (size_t operation_index = 0; operation_index < operation_count;
       ++operation_index) {
    const auto operation = operations[operation_index];
    CppMapObservation observation = {};
    observation.kind = operation.kind;
    observation.inserted = -1;
    observation.rank = -1;
    observation.upper_rank = -1;
    observation.count = -1;
    observation.range_offset = contents_offset;

    const bool is_hinted =
        operation.kind == CPP_MAP_OPERATION_INSERT_HINT ||
        operation.kind == CPP_MAP_OPERATION_INSERT_OR_ASSIGN_HINT;
    if (is_hinted && (operation.position < 0 ||
                      static_cast<size_t>(operation.position) > map.size())) {
      return CPP_MAP_TRACE_INVALID_POSITION;
    }

    switch (operation.kind) {
    case CPP_MAP_OPERATION_INSERT: {
      const auto result = map.insert({operation.key, operation.value});
      observation.inserted = result.second ? 1 : 0;
      observation.has_entry = true;
      observation.entry = entry_of(result.first);
      observation.rank = rank_of(result.first);
      break;
    }
    case CPP_MAP_OPERATION_INSERT_HINT: {
      auto hint = map.cbegin();
      std::advance(hint, operation.position);
      const auto previous_size = map.size();
      const auto result = map.insert(hint, {operation.key, operation.value});
      observation.inserted = map.size() != previous_size ? 1 : 0;
      observation.has_entry = true;
      observation.entry = entry_of(result);
      observation.rank = rank_of(result);
      break;
    }
    case CPP_MAP_OPERATION_INSERT_OR_ASSIGN:
    case CPP_MAP_OPERATION_INSERT_OR_ASSIGN_HINT: {
      // The package compiles C++ below C++17, so `insert_or_assign` is spelled
      // out with its specified effect: assign through an existing element, or
      // insert a new one.
      const auto existing = map.find(operation.key);
      observation.reports_previous = true;
      observation.has_previous = existing != map.end();
      if (observation.has_previous) {
        observation.previous_value = existing->second;
        existing->second = operation.value;
      } else if (operation.kind == CPP_MAP_OPERATION_INSERT_OR_ASSIGN) {
        map.insert({operation.key, operation.value});
      } else {
        auto hint = map.cbegin();
        std::advance(hint, operation.position);
        map.insert(hint, {operation.key, operation.value});
      }
      break;
    }
    case CPP_MAP_OPERATION_SUBSCRIPT_ASSIGN:
      map[operation.key] = operation.value;
      break;
    case CPP_MAP_OPERATION_SUBSCRIPT_ADD:
      map[operation.key] += operation.value;
      break;
    case CPP_MAP_OPERATION_FIND: {
      const auto result = map.find(operation.key);
      observation.has_entry = result != map.end();
      if (observation.has_entry) {
        observation.entry = entry_of(result);
      }
      observation.rank = rank_of(result);
      observation.count = static_cast<int64_t>(map.count(operation.key));
      break;
    }
    case CPP_MAP_OPERATION_LOWER_BOUND:
    case CPP_MAP_OPERATION_UPPER_BOUND: {
      const auto result = operation.kind == CPP_MAP_OPERATION_LOWER_BOUND
                              ? map.lower_bound(operation.key)
                              : map.upper_bound(operation.key);
      observation.has_entry = result != map.end();
      if (observation.has_entry) {
        observation.entry = entry_of(result);
      }
      observation.rank = rank_of(result);
      break;
    }
    case CPP_MAP_OPERATION_EQUAL_RANGE: {
      const auto range = map.equal_range(operation.key);
      const auto count =
          static_cast<size_t>(std::distance(range.first, range.second));
      if (contents_capacity - contents_offset < count) {
        return CPP_MAP_TRACE_INSUFFICIENT_CONTENTS;
      }
      observation.rank = rank_of(range.first);
      observation.upper_rank = rank_of(range.second);
      copy_entries(range.first, range.second);
      observation.range_count = count;
      break;
    }
    case CPP_MAP_OPERATION_ERASE_KEY:
      observation.count = static_cast<int64_t>(map.erase(operation.key));
      break;
    default:
      return CPP_MAP_TRACE_UNKNOWN_OPERATION;
    }

    if (contents_capacity - contents_offset < map.size()) {
      return CPP_MAP_TRACE_INSUFFICIENT_CONTENTS;
    }

    observation.contents_offset = contents_offset;
    observation.contents_count = map.size();
    copy_entries(map.cbegin(), map.cend());
    observations[operation_index] = observation;
  }

  return CPP_MAP_TRACE_SUCCESS;
}

int32_t cpp_multimap_execute_trace(
    const CppMultiMapOperation *operations,
    size_t operation_count,
    CppMultiMapObservation *observations,
    size_t observation_capacity,
    CppMapEntry *contents,
    size_t contents_capacity) {
  if (observation_capacity < operation_count) {
    return CPP_MULTIMAP_TRACE_INSUFFICIENT_OBSERVATIONS;
  }

  using MultiMap = std::multimap<int64_t, int64_t>;
  MultiMap map;
  size_t contents_offset = 0;

  const auto rank_of = [&map](MultiMap::const_iterator it) {
    return static_cast<int64_t>(std::distance(map.cbegin(), it));
  };
  const auto entry_of = [](MultiMap::const_iterator it) {
    return CppMapEntry{it->first, it->second};
  };
  const auto copy_entries = [&](MultiMap::const_iterator first,
                                MultiMap::const_iterator last) {
    for (; first != last; ++first) {
      contents[contents_offset++] = CppMapEntry{first->first, first->second};
    }
  };

  for (size_t operation_index = 0; operation_index < operation_count;
       ++operation_index) {
    const auto operation = operations[operation_index];
    CppMultiMapObservation observation = {};
    observation.kind = operation.kind;
    observation.rank = -1;
    observation.upper_rank = -1;
    observation.count = -1;
    observation.range_offset = contents_offset;

    // A hint may be `end()`; the other positional operations need an element.
    const bool is_hint = operation.kind == CPP_MULTIMAP_OPERATION_INSERT_HINT;
    const bool is_element =
        operation.kind == CPP_MULTIMAP_OPERATION_ERASE_AT ||
        operation.kind == CPP_MULTIMAP_OPERATION_REMOVE_AT ||
        operation.kind == CPP_MULTIMAP_OPERATION_ASSIGN_AT;
    if ((is_hint && (operation.position < 0 ||
                     static_cast<size_t>(operation.position) > map.size())) ||
        (is_element &&
         (operation.position < 0 ||
          static_cast<size_t>(operation.position) >= map.size()))) {
      return CPP_MULTIMAP_TRACE_INVALID_POSITION;
    }
    auto position = map.begin();
    if (is_hint || is_element) {
      std::advance(position, operation.position);
    }

    switch (operation.kind) {
    case CPP_MULTIMAP_OPERATION_INSERT:
      map.insert({operation.key, operation.value});
      break;
    case CPP_MULTIMAP_OPERATION_INSERT_HINT: {
      const auto result =
          map.insert(MultiMap::const_iterator(position),
                     {operation.key, operation.value});
      observation.has_entry = true;
      observation.entry = entry_of(result);
      observation.rank = rank_of(result);
      break;
    }
    case CPP_MULTIMAP_OPERATION_FIND: {
      const auto result = map.find(operation.key);
      observation.has_entry = result != map.end();
      if (observation.has_entry) {
        observation.entry = entry_of(result);
      }
      observation.rank = rank_of(result);
      observation.count = static_cast<int64_t>(map.count(operation.key));
      break;
    }
    case CPP_MULTIMAP_OPERATION_LOWER_BOUND:
    case CPP_MULTIMAP_OPERATION_UPPER_BOUND: {
      const auto result = operation.kind == CPP_MULTIMAP_OPERATION_LOWER_BOUND
                              ? map.lower_bound(operation.key)
                              : map.upper_bound(operation.key);
      observation.has_entry = result != map.end();
      if (observation.has_entry) {
        observation.entry = entry_of(result);
      }
      observation.rank = rank_of(result);
      break;
    }
    case CPP_MULTIMAP_OPERATION_EQUAL_RANGE: {
      const auto range = map.equal_range(operation.key);
      const auto count =
          static_cast<size_t>(std::distance(range.first, range.second));
      if (contents_capacity - contents_offset < count) {
        return CPP_MULTIMAP_TRACE_INSUFFICIENT_CONTENTS;
      }
      observation.rank = rank_of(range.first);
      observation.upper_rank = rank_of(range.second);
      copy_entries(range.first, range.second);
      observation.range_count = count;
      break;
    }
    case CPP_MULTIMAP_OPERATION_ERASE_KEY:
      observation.count = static_cast<int64_t>(map.erase(operation.key));
      break;
    case CPP_MULTIMAP_OPERATION_ERASE_AT:
      observation.rank = rank_of(map.erase(position));
      break;
    case CPP_MULTIMAP_OPERATION_REMOVE_AT:
      observation.has_entry = true;
      observation.entry = entry_of(position);
      map.erase(position);
      break;
    case CPP_MULTIMAP_OPERATION_ASSIGN_AT:
      observation.has_previous = true;
      observation.previous_value = position->second;
      position->second = operation.value;
      break;
    default:
      return CPP_MULTIMAP_TRACE_UNKNOWN_OPERATION;
    }

    if (contents_capacity - contents_offset < map.size()) {
      return CPP_MULTIMAP_TRACE_INSUFFICIENT_CONTENTS;
    }

    observation.contents_offset = contents_offset;
    observation.contents_count = map.size();
    copy_entries(map.cbegin(), map.cend());
    observations[operation_index] = observation;
  }

  return CPP_MULTIMAP_TRACE_SUCCESS;
}
