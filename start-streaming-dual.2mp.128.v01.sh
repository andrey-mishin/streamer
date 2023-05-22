#!/bin/bash
# Добавить проверку наличие достаточного кол-ва интерфейсов

killall vlc && echo "VLC was killed"
sleep 2

if [[ $1 -eq 0 ]]
then
  echo "Please enter a value greater than 0"
  exit 1
else

in=$(( $1 + 100 ))

  if [[ $1 -le 128 ]]
  then

  st=0

    for i in $( seq 101 $in )
    do
      /snap/bin/vlc -I dummy -vvv -L --syslog /home/mishin/ltv-box/video/h264/2Mp/one.wild.day.1080p.2mp.mkv --start-time $st --sout "#rtp{sdp=rtsp://192.168.0.$i:554/test4}" --sout-rtsp-user admin --sout-rtsp-pwd 12345678 2>/dev/null &
      /snap/bin/vlc -I dummy -vvv -L --syslog /home/mishin/ltv-box/video/h264/d1/one.wild.day.576p.d1.mkv --start-time $st --sout "#rtp{sdp=rtsp://192.168.1.$i:554/test1}" --sout-rtsp-user admin --sout-rtsp-pwd 12345678 2>/dev/null &
      
      let st=$(( st + 5 ))

      if [[ $out -eq 0 ]]
      then
        echo "Main stream on 192.168.0.$i and additional stream on 192.168.1.$i were created."
      fi

    done

  else
    echo "Too much streams!"
    exit 1
  fi
fi

exit
