#!/usr/bin/env sh
# shellcheck shell=sh

apiUrl="$HIVEOS_API_URL"
authToken="$HIVEOS_AUTH_TOKEN"
primaryAndZilFs="$PRIMARY_AND_ZIL_FS"
primaryFs="$PRIMARY_FS"

switchFs() {
  curl "$apiUrl" -X PATCH -sSL \
    -H "Content-Type: application/json" \
    -H "X-API-Version: 2.8" \
    -H "Authorization: Bearer $authToken" \
    --data-raw "{\"fs_id\":$1}"
}

getTimeUntilNextEpoch() {
  lastEpochBlock=$(curl 'https://api.zilliqa.com/' -sSL -X POST \
    -H 'Content-Type: application/json' \
    --data-raw '{"id":1,"jsonrpc":"2.0","method":"GetBlockchainInfo","params":[]}' | grep -Eo '"CurrentDSEpoch":"[0-9]+"' | cut -b 18-)

  lastEpoch=$(curl 'https://api.zilliqa.com/' -sSL -X POST \
    -H 'Content-Type: application/json' \
    --data-raw '{"id":1,"jsonrpc":"2.0","method":"GetDsBlock","params":['"$lastEpochBlock]}" | grep -Eo '"Timestamp":"[0-9]+' | cut -b 14-)

  unix=$((lastEpoch / 1000000))

  now="$(date +%s)"
  diff=$((now - unix))
  # We estimate that zil epochs are about 3960 seconds and a mining window is
  # about 120 seconds.
  # Source: https://devex.zilliqa.com/dsbk?network=https%3A%2F%2Fapi.zilliqa.com
  untilNext=$((unix - now + 3960 - 120))

  echo "$untilNext"
}

while true;
do
  diff=$(getTimeUntilNextEpoch)
  echo "$diff"
  if [ "$diff" -lt 0 ]; then
    # Do nothing
    true
  else
    if [ "$diff" -lt 100 ]; then
      echo switching to nexa+zil
      switchFs "$primaryAndZilFs"
      echo waiting for next block...
      while true;
      do
        diff=$(getTimeUntilNextEpoch)
        if [ "$diff" -gt 1000 ]; then
          echo new block found
          break
        fi
        
        echo .
        sleep 5
      done

      echo switching back to nexa only
      switchFs "$primaryFs"
    fi
  fi
  
  sleep 20
done
