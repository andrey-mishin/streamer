#!/bin/bash
# Добавить проверку наличие достаточного кол-ва интерфейсов
# Добавить сдвиг по времени для каждого нового потока на 10 сек.

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

      out=$?

      let st=$(( st + 10 ))

      if [[ $out -eq 0 ]]
      then
        echo "Main stream on 192.168.0.$i was created."
      fi

    done

  else
    echo "Too much streams!"
    exit 1
  fi
fi

exit
