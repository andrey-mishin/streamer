#!/bin/bash
# Добавить проверку наличие достаточного кол-ва интерфейсов

if [[ $1 -eq 0 ]]
then
  echo "Please enter a value greater than 0"
  exit 1
else

in=$(( $1 + 100 ))

  if [[ $1 -le 100 ]]
  then

  st=0

    for i in $( seq 101 $in )
    do
      /usr/bin/cvlc -vvv -L --syslog /home/baloo/ltv-box/video/h264/2Mp/wwbf.1080p.2mp.mkv --start-time $st --sout "#rtp{sdp=rtsp://192.168.0.$i:554/test4}" --sout-rtsp-user admin --sout-rtsp-pwd 12345678 2>/dev/null &
      /usr/bin/cvlc -vvv -L --syslog /home/baloo/ltv-box/video/h264/D1/wwbf.576p.d1.mkv --start-time $st --sout "#rtp{sdp=rtsp://192.168.0.$((i+$1)):554/test1}" --sout-rtsp-user admin --sout-rtsp-pwd 12345678 2>/dev/null &
      
      let st=$(( st + 10 ))

      if [[ $out -eq 0 ]]
      then
        echo "Main stream on 192.168.0.$i and additional stream on 192.168.0.$((i+$1)) were created."
      fi

    done

  else
    echo "Too much streams!"
    exit 1
  fi
fi

exit
