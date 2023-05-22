#!/bin/bash

echo "Enter number of interfaces:"
read num

for i in $( seq 0 $num )
do 
  ip link delete rtsp$i
done
