#!/usr/bin/env bash

apiUrl="$HIVEOS_API_URL"
authToken="$HIVEOS_AUTH_TOKEN"
primaryAndZilFs="$PRIMARY_AND_ZIL_FS"
primaryFs="$PRIMARY_FS"

switchFs() {
  curl '$apiUrl' -X PATCH \
    -H 'Content-Type: application/json' \
    -H 'X-API-Version: 2.8' \
    -H 'Authorization: Bearer $authToken' \
    --data-raw "{\"fs_id\":$1}"
}

while true;
do
  nextEpoch="$(curl -sS 'https://zil.crazypool.org/api/stats/chart' | grep -Eo "\"nextEpochTime\":[0-9]+" | cut -b 17-)"
  now="$(date +%s)"
  diff=$(($nextEpoch-$now))
  echo $diff
  if [ $diff -lt 0 ]; then
    # Do nothing
    true
  else
    if [ $diff -lt 100 ]; then
      echo switching to nexa+zil
      switchFs "$primaryAndZilFs"
      sleep $(($diff+120))
      echo switching back to nexa only
      switchFs "$primaryFs"
    fi
  fi
  
  sleep 20
done
