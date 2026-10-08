STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}-adhoc

mkdir -p ./Results/2M/Adhoc

swift run -c release benchmark library run \
  --library ./Libraries/Adhoc.json \
  ./Results/2M/Adhoc/results-${ID}.json \
  --max-size 2M \
  --cycles 1 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/Adhoc.json \
  ./Results/2M/Adhoc/results-${ID}.json \
  --max-time 10us \
  --min-time 1ns \
  --percentile 90 \
  --output .

swift package clean
