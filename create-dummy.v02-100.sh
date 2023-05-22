#!/bin/bash

if [[ $1 -eq 0 ]]
then
  echo "Please enter a value greater than 0"
  exit
else

in=$(( $1 + 100 ))

  if [[ $1 -le 128 ]]
  then
    for i in $( seq 101 $in ) 
    do 
      ip link add name rtsp$i type dummy 2>/dev/null && ip address add 192.168.100.$i/32 dev rtsp$i 2>/dev/null
      out=$?

      if [[ $out -eq 0 ]]
      then
        echo "Interface rtsp$i has been created"
      fi

    done
  else
    echo "Too much interfaces!"
  fi

  if [[ $out -ne 0 ]]
  then
    echo "WARNING! Somthing went wrong! Did you use SUDO? Or maybe interface(s) exist!"
  fi

fi

exit
