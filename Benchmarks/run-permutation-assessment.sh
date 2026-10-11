#!/bin/bash
set -euo pipefail

STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}-permutation-assessment
ASSESSMENT_DIR=./QualityAssessment/macOS/Permutations
RESULT_PATH=${ASSESSMENT_DIR}/Results/${ID}.json
CHART_PATH=${ASSESSMENT_DIR}/Charts/${ID}.png
CHART_STAGE=${ASSESSMENT_DIR}/Charts/.${ID}
ENVIRONMENT_DIR=${ASSESSMENT_DIR}/Environments/${ID}

mkdir -p "${ASSESSMENT_DIR}/Results"
mkdir -p "${ASSESSMENT_DIR}/Charts"
mkdir -p "${ENVIRONMENT_DIR}"
mkdir -p "${CHART_STAGE}"

git rev-parse HEAD > "${ENVIRONMENT_DIR}/commit.txt"
sw_vers > "${ENVIRONMENT_DIR}/macOS.txt"
uname -a > "${ENVIRONMENT_DIR}/uname.txt"
system_profiler SPHardwareDataType > "${ENVIRONMENT_DIR}/hardware.txt"
xcrun swift --version > "${ENVIRONMENT_DIR}/swift.txt"
xcrun clang++ --version > "${ENVIRONMENT_DIR}/clang.txt"

swift run -c release benchmark library run \
  --library ./Libraries/PermutationAssessment.json \
  "${RESULT_PATH}" \
  --sizes 8 12 16 20 24 28 32 \
  --cycles 5 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/PermutationAssessment.json \
  "${RESULT_PATH}" \
  --amortized false \
  --format png \
  --multifile \
  --output "${CHART_STAGE}"

mv \
  "${CHART_STAGE}/PermutationAssessment/binary-selection/01 Binary selections ending at 32 choose 7.png" \
  "${CHART_PATH}"
rm "${CHART_STAGE}/Results.md"
rmdir "${CHART_STAGE}/PermutationAssessment/binary-selection"
rmdir "${CHART_STAGE}/PermutationAssessment"
rmdir "${CHART_STAGE}"

printf '%s\n' "${ASSESSMENT_DIR}"
