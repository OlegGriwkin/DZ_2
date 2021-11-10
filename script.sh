#!/bin/bash

#Получение списка параметров
sudo lshw -short | grep disk
#Запуск утилиты
sudo fdisk -l
#Зануление суперблоков
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
#Создание рейда
mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
#Проверка рейда
cat /proc/mdstat
#Запуск утилиты для управления прог-ми RAID-массивами
mdadm -D /dev/md0
#Создание директории для mdadm.conf
mkdir /etc/mdadm
#Получение информации. Элемент <details> используется для раскрытия скрытой (дополнительной) информации.
mdadm --detail --scan --verbose
#Создание конфигурационного файла mdadm.conf
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >>/etc/mdadm/mdadm.conf
# Искусственно "зафейлим" блочное устройство md0
mdadm /dev/md0 --fail /dev/sde
#Проверка рейда
cat /proc/mdstat
#Запуск утилиты для управления прог-ми RAID-массивами
mdadm -D /dev/md0
#Удаленние "зафейлиного" диска
mdadm /dev/md0 --remove /dev/sde
#Добавление нового диска
mdadm /dev/md0 --add /dev/sde
#Проверка рейда
cat /proc/mdstat
#Запуск утилиты для управления прог-ми RAID-массивами
mdadm -D /dev/md0
#Создаем раздел GPT на RAID
parted -s /dev/md0 mklabel gpt
#Создаем партиции
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
#Создаем Файловую Систему (ФС)
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
#Монтируем портации по каталогам
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done








