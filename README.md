# Запись всего, что было сделано

# Идеи дальнейших действий
- Собрать единый скрипт поднимающий требуемое количество интерфейсов и потоков, принимающий на входе битрейт и кол-во потоков.
- Нарисовать web-морду, где можно выбирать кол-во потоков и битрейт
- Добить вопрос с объединением двух потоков на 1 IP (возможно, переехать на https://github.com/bluenviron/mediamtx и ffmpeg)
...


### Работа с видеофайлами при помощи FFMPEG (и немного SED)

- Склеивание файлов. Склеивание получилось сделать только по методу 3 (concat protocol).
Брал [отсюда](https://stackoverflow.com/questions/7333232/how-to-concatenate-two-mp4-files-using-ffmpeg)  
Изначально было 4 файла с именами `StormStock_[1-4].mov`. Нужно было записать их в текстовый файл в таком формате:
```
file './StormStock_1.mov'
file './StormStock_2.mov'
file './StormStock_3.mov'
file './StormStock_4.mov'
```

**В файлик StormStock.txt записал нужныe строки используя SED:**  
```
sed -i -e "s/^/file '.\//;s/$/'/" StormStock.txt
```

- Склеивание:  
```
ffmpeg -f concat -safe 0 -i StormStock.txt -c copy StormStock_all.mov
```
- Удалить аудио:  
```
ffmpeg -i StormStock_all.mov -c copy -an StormStock_all_woa.mov
```
- Удалить субтитры:
```
ffmpeg -i StormStock_all.mov -c copy -sn <имя_файла.mov>
```
- Типа подрезать битрейт
```
ffmpeg -i StormStock_all_woa.mov -b 4096k StormStock_4M_h264.mov
```
- Похоже нужно делать MP4. Поэтому буду использовать команду:
```
ffmpeg -i StormStock_1.mov -c copy StormStock_1.mp4
```
- Изменение разрешения
```
ffmpeg -i input.mp4 -vf scale=480:320 output_320.mp4
```
- Изменение разрешения и соотношение сторон
```
ffmpeg -i input.mp4 -vf scale=480:320,setdar=4:3 output_320.mp4
```    
   
===========================================================================
  
  
### Стриминг. Работа с VLC

**Для работы из командной строки используется `cvlc`, либо `vlc -I dummy`**  
**!!!!!! DST и порт можно убрать !!!!!!**


- Стриминг файла по RTSP получилось:
```
cvlc -vvv /home/baloo/Downloads/The.Mandalorian.S01E08.WEB-DL.720p.LostFilm.mkv --sout '#rtp{dst=127.0.0.1,port=1234,sdp=rtsp://192.168.0.142:8080/test.sdp}'
```

- Можно запускать стриминг даже с smb server:
```
cvlc -vvv /run/user/1000/gvfs/smb-share:server=mediaserver.local,share=storage/Andor.S01.WEB-DL.720p.Rus.Eng/Andor.S01E01.WEB-DL.720p.RGzsRutracker.mkv --start-time 300 --sout '#rtp{dst=192.168.0.142,port=1234,sdp=rtsp://192.168.0.142:8080/test.sdp}'
```

- Для сдвига по времени есть флаг `--start-time <время сдвига в секундах>`  
```
cvlc -vvv --file-logging /storage/Andor.S01.WEB-DL.720p.Rus.Eng/Andor.S01E02.WEB-DL.720p.RGzsRutracker.mkv --start-time 160 --mtu 1200 --sout '#rtp{dst=127.0.0.2,port=1200,sdp=rtsp://192.168.0.223:8554/test.sdp}'
```

- Авторизация по RTSP. Нужно добавить `--sout-rtsp-user` и `--sout-rtsp-pwd`  
```
cvlc -vvv -L ./spring-D1-WoA.mp4 --sout '#rtp{dst=127.0.0.1,port=1234,sdp=rtsp://192.168.0.55:554/test.sdp}' --sout-rtsp-user admin --sout-rtsp-pwd 123456  
```

- Варианты повтора видео
```
  -L, --loop, --no-loop          Repeat all
                                 (default disabled)
          VLC will keep playing the playlist indefinitely.
  -R, --repeat, --no-repeat      Repeat current item
                                 (default disabled)
          VLC will keep playing the current playlist item.
```

- Логирование в системный лог `syslog`
```
 System logger (syslog) (syslog)
      --syslog, --no-syslog      System log (syslog)
          Emit log messages through the POSIX system log.
      --syslog-debug, --no-syslog-debug 
          Include debug messages in system log.
      --syslog-ident <string>    Identity
          Process identity in system log.
      --syslog-facility {user,daemon,local0,local1,local2,local3,local4,local5,local6,local7} 
          System logging facility.
```

- Логирование в лог-файл
```
 File logger (file)
      --file-logging, --no-file-logging 
      --logfile <string>         Log filename
          Specify the log filename.
      --logmode {text,html}      Log format
          Specify the logging format.
      --log-verbose {-1 (Default), 0 (Info), 1 (Error), 2 (Warning), 3 (Debug)} 
```

===========================================================================

### Работа в Linux

- Решение проблемы открытия порта 554 без запуска VLC с рутовыми правами
МОЖНО просто уменьшить диапазон зарегистрированных портов:  
```
sudo sysctl net.ipv4.ip_unprivileged_port_start=553
```
- Скрипт создаёт нужное количество `dummy` интерфейсов. Количество интерфейсов отдаётся первым аргументом ($1) при запуске скрипта.
```
create-dummy.v02.sh <кол-во интерфейсов>
```
- Скрипт удаляет все `dummy` интерфейсы с именем `rtsp*`
```
remove-dummy-all.v02.sh
```
- Скрипт поднимающий нужное количество копий `vlc`. Количество потоков отдаётся первым аргументом при запуске скрипта.  
Скрипт поднимает сразу два потока - основной и дополнительный. Это сделано потому, что пока не реализован механизм получения двух потоков по уникальному `URL`с одного `ip:port` как сделано в камерах. См. следующий вопрос.   
(!!!)На вход подаётся количество ОСНОВНЫХ потоков. Дополнительные поднимаются автоматически. В итоге процессов и потоков будет в 2 раза больше чем подано на вход скрипту.   
Этот скрипт требует доработки:  
  - Добавить проверку наличия достаточного кол-ва интерфейсов
  - Добавить свиг по времени для каждого нового потока на 10 сек.

```
start-streaming.sh
```
- Сделал несколько отдельных скриптов запускающих основной и второстепенный потоки под разный битрейт. Ещё осталось несколько тестовых скриптов, в том числе запускающих только основной (main) и только второстепенный (add) потоки.
```
start-streaming-dual.2mp.v01.sh
start-streaming-dual.4mp.v01.sh
start-streaming-dual.5mp.v01.sh
start-streaming-dual.8mp.v01.sh
start-streaming-dual.v01.sh
``` 

- Нужен HTTP/RTMP (???) proxy для отдачи разных потоков с одного `ip:port` по разным `URL`.  
```
```



===========================================================================

### Вопросы (требует корректировки)

**В Ubuntu Server 22.04 нужно собирать `vlc` из [исходников](https://wiki.videolan.org/UnixCompile/) или откатываться на 20.04. VLC из SNAP не заработал.**

**Запуск скриптов без `SUDO` можно сделать [добавив пути](https://serverfault.com/questions/75620/ubuntu-let-a-user-run-a-script-with-root-permissions) к скриптам в `SUDOERS` файл**

**Нужно определить:**  
- как запустить несколько параллельных потоков с разными source/port, которые будут отдаваться по rtsp по запросу
запускать несколько процессов параллельно с разными портами для dst (с шагом 10, чтобы избежать накладки со звуковыми дорожками на отдельных портах) и для rtsp
НО, нужен способ изящней, с разными src ip-адресами - dummy интерфейсы??
```
sudo ip link add name rtsp0 type dummy
sudo ip address add 192.168.0.222/32 dev rtsp0
```

(НЕ АКТУАЛЬНО) Чтобы запустить vlc на порту 554 нужно запускать его от root, т.к. до 1024 зарегистрированные порты. 
Чтобы сделать это нужен либо sudo vlc-wrapper, либо корректировка бинарника vlc:  
```
sudo sed -i 's/geteuid/getppid/' /usr/bin/vlc
```
После этого можно запускать vlc с sudo от рута.

МОЖНО просто уменьшить диапазон зарегистрированных портов:
```
sudo sysctl net.ipv4.ip_unprivileged_port_start=553
```


!!! Нужно рассмотреть вариант с пробросом портов в UFW. Например, поднимать vlc на порту 8554, но принимать запросы на 554 и отправлять в vlc.


- как запускать несколько файлов друг за другом по списку без отвала RTSP
можно перечислить их в самой команде, но избежать отвала не получается
наверняка есть плейлист, но без отвала наверняка тоже не получится  
!возможно, оно и не надо ибо проще найти большой файл на 10-12 часов и гонять его

- как крутить одно видео по кругу без перерыва в воспроизведении и без отвала RTSP
пока нашёл только варианты -L (loop) и -R (repeate), но при перезапуске потока клиент RTSP отваливается (((



===========================================================================

### DOCKER with VLC

Есть [докер контейнер](https://hub.docker.com/r/galexrt/vlc). На базе убунты развёрнут VLC.

Описание на hub.docker.com  
Запускать контейнер нужно так:
1. Running the image
`docker run -d -v "$(pwd)":/data quay.io/galexrt/vlc:latest YOUR_VLC_FLAGS`

2. HTTP based video stream (TCP)
This will start a HTTP based video stream on port 8080/tcp.

`docker run -d -v "$(pwd)":/data -p 8080:8080 quay.io/galexrt/vlc:latest file:///data/your-video-file.mp4 --sout '#transcode{scodec=none}:http{mux=ffmpeg{mux=flv},dst=:8080/}'`

3. RTSP stream (UDP)
This will start a RTSP stream on port 8554/udp.

`docker run -d -v "$(pwd)":/data -p 8554:8554/udp quay.io/galexrt/vlc:latest file:///data/your-video-file.mp4 --sout '#transcode{scodec=none}:rtp{sdp=rtsp://:8554/}'`

===========================================================================



