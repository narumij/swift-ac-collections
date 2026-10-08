#!/bin/bash
set -euo pipefail

STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}-ci

mkdir -p ./Results/CI

swift run -c release benchmark library run \
  --library ./Libraries/CI.json \
  ./Results/CI/results-${ID}.json \
  --max-size 256k \
  --cycles 1 \
  --mode replace-all
