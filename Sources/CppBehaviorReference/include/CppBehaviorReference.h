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

#ifdef __cplusplus
}
#endif

#endif
