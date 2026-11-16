STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}-long2

mkdir -p ./Results/16M/Long

swift run -c release benchmark library run \
  --library ./Libraries/Long2.json \
  ./Results/16M/Long/results-${ID}.json \
  --max-size 16M \
  --cycles 1 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/Long2.json \
  ./Results/16M/Long/results-${ID}.json \
  --max-time 10us \
  --min-time 1ns \
  --percentile 90 \
  --output .

swift package clean
