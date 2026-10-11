#!/bin/bash
set -euo pipefail

STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}-bare-array-assessment
ASSESSMENT_DIR=./QualityAssessment/macOS/BareArray
RESULT_PATH=${ASSESSMENT_DIR}/Results/${ID}.json
CHART_DIR=${ASSESSMENT_DIR}/Charts
CHART_STAGE=${CHART_DIR}/.${ID}
ENVIRONMENT_DIR=${ASSESSMENT_DIR}/Environments/${ID}

mkdir -p "${ASSESSMENT_DIR}/Results"
mkdir -p "${CHART_DIR}"
mkdir -p "${ENVIRONMENT_DIR}"
mkdir -p "${CHART_STAGE}"

git rev-parse HEAD > "${ENVIRONMENT_DIR}/commit.txt"
sw_vers > "${ENVIRONMENT_DIR}/macOS.txt"
uname -a > "${ENVIRONMENT_DIR}/uname.txt"
system_profiler SPHardwareDataType > "${ENVIRONMENT_DIR}/hardware.txt"
xcrun swift --version > "${ENVIRONMENT_DIR}/swift.txt"
xcrun clang++ --version > "${ENVIRONMENT_DIR}/clang.txt"

swift run -c release benchmark library run \
  --library ./Libraries/BareArrayAssessment.json \
  "${RESULT_PATH}" \
  --max-size 64k \
  --cycles 5 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/BareArrayAssessment.json \
  "${RESULT_PATH}" \
  --amortized false \
  --format png \
  --multifile \
  --output "${CHART_STAGE}"

GENERATED_DIR=${CHART_STAGE}/BareArrayAssessment/nested-vector
mv "${GENERATED_DIR}/01 2D sequential read checksum.png" "${CHART_DIR}/${ID}-2d-read.png"
mv "${GENERATED_DIR}/02 2D sequential write.png" "${CHART_DIR}/${ID}-2d-write.png"
mv "${GENERATED_DIR}/03 3D sequential read checksum.png" "${CHART_DIR}/${ID}-3d-read.png"
mv "${GENERATED_DIR}/04 3D sequential write.png" "${CHART_DIR}/${ID}-3d-write.png"
rm "${CHART_STAGE}/Results.md"
rmdir "${GENERATED_DIR}"
rmdir "${CHART_STAGE}/BareArrayAssessment"
rmdir "${CHART_STAGE}"

printf '%s\n' "${ASSESSMENT_DIR}"
