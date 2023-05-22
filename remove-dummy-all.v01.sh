# Скрипт удаляет все dummy интерфейсы с именем rtsp*

#!/bin/bash

for i in $( ip link | awk -F ": " '/rtsp/ {print $2}' )
do
  ip link delete $i
  out=$?
      if [[ $out -eq 0 ]]
      then
        echo "$i interface has been deleted."
      else
        echo "WARNING! Somthing went wrong! Interface(s) doesn't exist."
      fi
done

if [[ $out -eq 2 ]]
then
  echo "WARNING! Somthing went wrong! Did you use SUDO?"
fi

exit


# не могу решить задачку с выводом нужного комментария если забыл SUDO или интерфейс уже не существует
# если 0, значит интерфейсы существуют и SUDO используется
# если 1, значит интерфейса не существует
# если 2, значит забыл SUDO
