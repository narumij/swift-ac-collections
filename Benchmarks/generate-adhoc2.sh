STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}-adhoc

mkdir -p ./Results/2M/Adhoc2

swift run -c release benchmark library run \
  --library ./Libraries/Adhoc2.json \
  ./Results/2M/Adhoc2/results-${ID}.json \
  --max-size 2M \
  --cycles 3 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/Adhoc2.json \
  ./Results/2M/Adhoc2/results-${ID}.json \
  --max-time 10us \
  --min-time 1ns \
  --percentile 90 \
  --output .

swift package clean
