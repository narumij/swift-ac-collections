STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}-adhoc

mkdir -p ./Results/256k/Adhoc6

swift run -c release benchmark library run \
  --library ./Libraries/AdHoc.json \
  ./Results/256k/Adhoc6/results-${ID}.json \
  --max-size 256k \
  --cycles 1 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/AdHoc.json \
  ./Results/256k/Adhoc6/results-${ID}.json \
  --max-time 10us \
  --min-time 1ns \
  --percentile 90 \
  --output .

swift package clean
