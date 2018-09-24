#!/bin/bash

function main() {
  local readonly LATEST_RESULT_JSON="bench-result_latest.json"
  cd /home/isucon/torb/bench/
  bin/bench -remotes=127.0.0.1 -output ${LATEST_RESULT_JSON}
  cp ${LATEST_RESULT_JSON} bench-result_$(date "+%Y-%m-%d_%H-%M-%S").json
  echo
  echo "Score: $(cat ${LATEST_RESULT_JSON} | jq .score)"
}

main
