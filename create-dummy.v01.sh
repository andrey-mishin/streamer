#!/bin/bash

read -p "Enter the number of interfaces: " NUM
if [[ $NUM -le 9 ]]
then
  for i in $( seq 1 $NUM ) 
  do 
    echo "ip link add name rtsp$i type dummy"
    echo "ip address add 192.168.0.1$i/32 dev rtsp$i"
  done
else
  echo "Too much interfaces!"
fi
