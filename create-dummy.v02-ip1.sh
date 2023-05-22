#!/bin/bash

if [[ $1 -eq 0 ]]
then
  echo "Please enter a value greater than 0"
  exit 1
else

in=$(( $1 + 100 ))

  if [[ $1 -le 130 ]]
  then
    for i in $( seq 101 $in ) 
    do 
      ip link add name rtsp$i type dummy 2>/dev/null && ip address add 192.168.1.$i/32 dev rtsp$i 2>/dev/null
      out=$?

      if [[ $out -eq 0 ]]
      then
        echo "Interface rtsp$i has been created"
      fi

    done
  else
    echo "Too much interfaces!"
    exit 1
  fi

  if [[ $out -ne 0 ]]
  then
    echo "WARNING! Somthing went wrong! Did you use SUDO? Or maybe interface(s) exist!"
    exit 1
  fi

fi

exit
