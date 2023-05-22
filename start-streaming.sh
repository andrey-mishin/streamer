#!/bin/bash
# Добавить проверку наличие достаточного кол-ва интерфейсов
# Добавить сдвиг по времени для каждого нового потока на 10 сек.

if [[ $1 -eq 0 ]]
then
  echo "Please enter a value greater than 0"
  exit 1
else

in=$(( $1 + 100 ))

  if [[ $1 -le 100 ]]
  then
    for i in $( seq 101 $in )
    do
      /usr/bin/cvlc -vvv -L --syslog /home/baloo/ltv-box/video/4M/scotland-4M-720p.mkv --start-time 30 --sout "#rtp{sdp=rtsp://192.168.0.$i:554/test4}" --sout-rtsp-user admin --sout-rtsp-pwd 12345678 2>/dev/null &
      /usr/bin/cvlc -vvv -L --syslog /home/baloo/ltv-box/video/1M/scotland-1M-720p.mkv --start-time 30 --sout "#rtp{sdp=rtsp://192.168.0.$((i+$1)):554/test1}" --sout-rtsp-user admin --sout-rtsp-pwd 12345678 2>/dev/null &

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
