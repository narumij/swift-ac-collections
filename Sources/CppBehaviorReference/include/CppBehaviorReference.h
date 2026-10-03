#ifndef CPP_BEHAVIOR_REFERENCE_H
#define CPP_BEHAVIOR_REFERENCE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

enum {
  CPP_SET_OPERATION_INSERT = 0,
  CPP_SET_OPERATION_LOWER_BOUND = 1,
  CPP_SET_OPERATION_ERASE_KEY = 2,
  CPP_SET_OPERATION_INSERT_HINT = 3,
  CPP_SET_OPERATION_UPPER_BOUND = 4,
  /// `set.find(value)` and `set.count(value)`.
  CPP_SET_OPERATION_FIND = 5,
};

enum {
  CPP_SET_TRACE_SUCCESS = 0,
  CPP_SET_TRACE_INSUFFICIENT_OBSERVATIONS = 1,
  CPP_SET_TRACE_INSUFFICIENT_CONTENTS = 2,
  CPP_SET_TRACE_UNKNOWN_OPERATION = 3,
  CPP_SET_TRACE_INVALID_POSITION = 4,
};

typedef struct {
  int32_t kind;
  int64_t value;
  int64_t position;
} CppSetOperation;

typedef struct {
  int32_t kind;
  int64_t argument;
  bool boolean_result;
  bool has_value;
  int64_t value;
  /// `count(value)`, or -1 when not reported.
  int64_t count;
  size_t contents_offset;
  size_t contents_count;
} CppSetObservation;

/// Executes a complete operation trace against a fresh `std::set<int64_t>`.
///
/// One observation is written for every operation. The complete ordered set
/// contents after that operation are appended to `contents` and identified by
/// the observation's offset and count.
int32_t cpp_set_execute_trace(
    const CppSetOperation *operations,
    size_t operation_count,
    CppSetObservation *observations,
    size_t observation_capacity,
    int64_t *contents,
    size_t contents_capacity);

enum {
  CPP_MULTISET_OPERATION_INSERT = 0,
  CPP_MULTISET_OPERATION_INSERT_HINT = 1,
  CPP_MULTISET_OPERATION_LOWER_BOUND = 2,
  CPP_MULTISET_OPERATION_UPPER_BOUND = 3,
  CPP_MULTISET_OPERATION_EQUAL_RANGE = 4,
  CPP_MULTISET_OPERATION_ERASE_KEY = 5,
  /// `multiset.erase(it)` for the element at `position`.
  CPP_MULTISET_OPERATION_ERASE_AT = 6,
  /// Copies `*it` for the element at `position`, then `multiset.erase(it)`.
  CPP_MULTISET_OPERATION_REMOVE_AT = 7,
  /// `multiset.find(value) != multiset.end()` and `multiset.count(value)`.
  CPP_MULTISET_OPERATION_FIND = 8,
};

enum {
  CPP_MULTISET_TRACE_SUCCESS = 0,
  CPP_MULTISET_TRACE_INSUFFICIENT_OBSERVATIONS = 1,
  CPP_MULTISET_TRACE_INSUFFICIENT_CONTENTS = 2,
  CPP_MULTISET_TRACE_UNKNOWN_OPERATION = 3,
  CPP_MULTISET_TRACE_INVALID_POSITION = 4,
};

typedef struct {
  int32_t kind;
  int64_t value;
  int64_t position;
} CppMultiSetOperation;

typedef struct {
  int32_t kind;
  int64_t argument;
  bool has_value;
  int64_t value;
  /// Zero-based rank of the returned position, or -1 when not reported.
  int64_t rank;
  /// Number of erased elements, or -1 when not reported.
  int64_t erased_count;
  /// Whether `find` located an element; meaningful only when `count` >= 0.
  bool found;
  /// `count(value)`, or -1 when not reported.
  int64_t count;
  size_t range_offset;
  size_t range_count;
  size_t contents_offset;
  size_t contents_count;
} CppMultiSetObservation;

/// Executes a complete operation trace against a fresh
/// `std::multiset<int64_t>`.
///
/// One observation is written for every operation. The elements of an
/// `equal_range` result, followed by the complete ordered contents after the
/// operation, are appended to `contents` and identified by the observation's
/// offsets and counts.
int32_t cpp_multiset_execute_trace(
    const CppMultiSetOperation *operations,
    size_t operation_count,
    CppMultiSetObservation *observations,
    size_t observation_capacity,
    int64_t *contents,
    size_t contents_capacity);

enum {
  /// `map.insert({key, value})`; an existing mapped value is preserved.
  CPP_MAP_OPERATION_INSERT = 0,
  /// `map.insert(hint, {key, value})`; an existing mapped value is preserved.
  CPP_MAP_OPERATION_INSERT_HINT = 1,
  /// The effect of `map.insert_or_assign(key, value)`: `map.find(key)` reports
  /// the previous mapped value, which is then assigned through the iterator, or
  /// `map.insert({key, value})` when absent.
  CPP_MAP_OPERATION_INSERT_OR_ASSIGN = 2,
  /// The effect of `map.insert_or_assign(hint, key, value)`: as above, but an
  /// absent key is inserted with `map.insert(hint, {key, value})`.
  CPP_MAP_OPERATION_INSERT_OR_ASSIGN_HINT = 3,
  /// `map[key] = value`.
  CPP_MAP_OPERATION_SUBSCRIPT_ASSIGN = 4,
  /// `map[key] += value`, where an absent key is value-initialized to zero.
  CPP_MAP_OPERATION_SUBSCRIPT_ADD = 5,
  /// `map.find(key)` and `map.count(key)`.
  CPP_MAP_OPERATION_FIND = 6,
  CPP_MAP_OPERATION_LOWER_BOUND = 7,
  CPP_MAP_OPERATION_UPPER_BOUND = 8,
  CPP_MAP_OPERATION_EQUAL_RANGE = 9,
  /// `map.erase(key)`.
  CPP_MAP_OPERATION_ERASE_KEY = 10,
};

enum {
  CPP_MAP_TRACE_SUCCESS = 0,
  CPP_MAP_TRACE_INSUFFICIENT_OBSERVATIONS = 1,
  CPP_MAP_TRACE_INSUFFICIENT_CONTENTS = 2,
  CPP_MAP_TRACE_UNKNOWN_OPERATION = 3,
  CPP_MAP_TRACE_INVALID_POSITION = 4,
};

typedef struct {
  int32_t kind;
  int64_t key;
  int64_t value;
  int64_t position;
} CppMapOperation;

typedef struct {
  int64_t key;
  int64_t value;
} CppMapEntry;

typedef struct {
  int32_t kind;
  /// 1 when an element was inserted, 0 when not, or -1 when not reported.
  int8_t inserted;
  bool has_entry;
  CppMapEntry entry;
  /// Zero-based rank of the returned position, or -1 when not reported.
  int64_t rank;
  /// Zero-based rank of the upper end of an `equal_range`, or -1.
  int64_t upper_rank;
  /// Whether `has_previous` and `previous_value` are reported.
  bool reports_previous;
  bool has_previous;
  int64_t previous_value;
  /// `count(key)` or the number of erased elements, or -1 when not reported.
  int64_t count;
  size_t range_offset;
  size_t range_count;
  size_t contents_offset;
  size_t contents_count;
} CppMapObservation;

/// Executes a complete operation trace against a fresh
/// `std::map<int64_t, int64_t>`.
///
/// One observation is written for every operation. The entries of an
/// `equal_range` result, followed by the complete ordered contents after the
/// operation, are appended to `contents` and identified by the observation's
/// offsets and counts.
int32_t cpp_map_execute_trace(
    const CppMapOperation *operations,
    size_t operation_count,
    CppMapObservation *observations,
    size_t observation_capacity,
    CppMapEntry *contents,
    size_t contents_capacity);

enum {
  /// `multimap.insert({key, value})`.
  CPP_MULTIMAP_OPERATION_INSERT = 0,
  /// `multimap.insert(hint, {key, value})`.
  CPP_MULTIMAP_OPERATION_INSERT_HINT = 1,
  /// `multimap.find(key)` and `multimap.count(key)`.
  CPP_MULTIMAP_OPERATION_FIND = 2,
  CPP_MULTIMAP_OPERATION_LOWER_BOUND = 3,
  CPP_MULTIMAP_OPERATION_UPPER_BOUND = 4,
  CPP_MULTIMAP_OPERATION_EQUAL_RANGE = 5,
  /// `multimap.erase(key)`.
  CPP_MULTIMAP_OPERATION_ERASE_KEY = 6,
  /// `multimap.erase(it)` for the element at `position`.
  CPP_MULTIMAP_OPERATION_ERASE_AT = 7,
  /// Copies `*it` for the element at `position`, then `multimap.erase(it)`.
  CPP_MULTIMAP_OPERATION_REMOVE_AT = 8,
  /// Copies `it->second` for the element at `position`, then assigns
  /// `it->second = value`.
  CPP_MULTIMAP_OPERATION_ASSIGN_AT = 9,
};

enum {
  CPP_MULTIMAP_TRACE_SUCCESS = 0,
  CPP_MULTIMAP_TRACE_INSUFFICIENT_OBSERVATIONS = 1,
  CPP_MULTIMAP_TRACE_INSUFFICIENT_CONTENTS = 2,
  CPP_MULTIMAP_TRACE_UNKNOWN_OPERATION = 3,
  CPP_MULTIMAP_TRACE_INVALID_POSITION = 4,
};

typedef struct {
  int32_t kind;
  int64_t key;
  int64_t value;
  int64_t position;
} CppMultiMapOperation;

typedef struct {
  int32_t kind;
  bool has_entry;
  CppMapEntry entry;
  /// Zero-based rank of the returned position, or -1 when not reported.
  int64_t rank;
  /// Zero-based rank of the upper end of an `equal_range`, or -1.
  int64_t upper_rank;
  /// Whether `previous_value` is reported.
  bool has_previous;
  int64_t previous_value;
  /// `count(key)` or the number of erased elements, or -1 when not reported.
  int64_t count;
  size_t range_offset;
  size_t range_count;
  size_t contents_offset;
  size_t contents_count;
} CppMultiMapObservation;

/// Executes a complete operation trace against a fresh
/// `std::multimap<int64_t, int64_t>`.
///
/// One observation is written for every operation. The entries of an
/// `equal_range` result, followed by the complete ordered contents after the
/// operation, are appended to `contents` and identified by the observation's
/// offsets and counts.
int32_t cpp_multimap_execute_trace(
    const CppMultiMapOperation *operations,
    size_t operation_count,
    CppMultiMapObservation *observations,
    size_t observation_capacity,
    CppMapEntry *contents,
    size_t contents_capacity);

#ifdef __cplusplus
}
#endif

#endif
