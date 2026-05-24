STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}

mkdir -p ./Results/2M/RedBlackTreeSet
mkdir -p ./Results/2M/RedBlackTreeDictionary

swift run -c release benchmark library run \
  --library ./Libraries/RedBlackTreeSet.json \
  ./Results/2M/RedBlackTreeSet/results-${ID}.json \
  --max-size 2M \
  --cycles 3 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/RedBlackTreeSet.json \
  ./Results/2M/RedBlackTreeSet/results-${ID}.json \
  --max-time 10us \
  --min-time 1ns \
  --percentile 90 \
  --output .

swift run -c release benchmark library run \
  --library ./Libraries/RedBlackTreeDictionary.json \
  ./Results/2M/RedBlackTreeDictionary/results-${ID}.json \
  --max-size 2M \
  --cycles 3 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/RedBlackTreeDictionary.json \
  ./Results/2M/RedBlackTreeDictionary/results-${ID}.json \
  --max-time 10us \
  --min-time 1ns \
  --percentile 90 \
  --output .

swift package clean
