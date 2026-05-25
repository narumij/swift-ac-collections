STAMP=$(date +%Y%m%d-%H%M%S)
COMMIT=$(git rev-parse --short HEAD)
ID=${STAMP}-${COMMIT}

mkdir -p ./Results/16M/RedBlackTreeSet
mkdir -p ./Results/16M/RedBlackTreeDictionary

swift run -c release benchmark library run \
  --library ./Libraries/RedBlackTreeSet.json \
  ./Results/16M/RedBlackTreeSet/results-${ID}.json \
  --max-size 16M \
  --cycles 3 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/RedBlackTreeSet.json \
  ./Results/16M/RedBlackTreeSet/results-${ID}.json \
  --max-time 10us \
  --min-time 1ns \
  --percentile 90 \
  --output .

swift run -c release benchmark library run \
  --library ./Libraries/RedBlackTreeDictionary.json \
  ./Results/16M/RedBlackTreeDictionary/results-${ID}.json \
  --max-size 16M \
  --cycles 3 \
  --mode replace-all

swift run -c release benchmark library render \
  --library ./Libraries/RedBlackTreeDictionary.json \
  ./Results/16M/RedBlackTreeDictionary/results-${ID}.json \
  --max-time 10us \
  --min-time 1ns \
  --percentile 90 \
  --output .

swift package clean
