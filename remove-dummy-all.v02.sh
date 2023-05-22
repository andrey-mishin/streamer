#!/bin/bash

for i in $( ip link | awk -F ": " '/rtsp/ {print $2}' )
do
  ip link delete $i 2>/dev/null
  out=$?
    if [[ $out -eq 0 ]]
    then
      echo "Interface $i has been deleted."
    fi
done

if [[ $out -gt 0 ]]
then
  echo "WARNING! Somthing went wrong!"
  exit 1
fi

exit
