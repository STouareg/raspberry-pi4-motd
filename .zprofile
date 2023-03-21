#!/bin/bash

USER=$(whoami)
HOSTNAME=$(uname -n)

MEMORY1=$(free -t -m | grep "Mem" | awk '{print $3}')
MEMORY2=$(free -t -m | grep "Mem" | awk '{print $2}')
MEMORY_TEMP=$((MEMORY1*100))
MEMORY_PERCENTAGE=$((MEMORY_TEMP/MEMORY2))


# time zone
TIME_ZONE=$(timedatectl | grep "Time zone" | awk -F ':' '{ print $2}')

# System uptime
uptime=$(< /proc/uptime cut -f1 -d.)
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))

# System load
LOAD1=$(< /proc/loadavg awk '{print $1}')
LOAD5=$(< /proc/loadavg awk '{print $2}')
LOAD15=$(< /proc/loadavg awk '{print $3}')
CPU_PERCENTAGE=$((100-$(vmstat 1 2|tail -1|awk '{print $15}')))

echo -e "
=======================================================================================================
\e[34m
████████╗██╗░░░██╗██████╗░██╗░░░██╗██╗░░██╗░██████╗  ██████╗░██╗░░██╗██╗
╚══██╔══╝██║░░░██║██╔══██╗╚██╗░██╔╝██║░██╔╝██╔════╝  ██╔══██╗██║░██╔╝██║
░░░██║░░░██║░░░██║██████╔╝░╚████╔╝░█████═╝░╚█████╗░  ██████╔╝██║██╔╝░██║
░░░██║░░░██║░░░██║██╔══██╗░░╚██╔╝░░██╔═██╗░░╚═══██╗  ██╔═══╝░██║███████║
░░░██║░░░╚██████╔╝██║░░██║░░░██║░░░██║░╚██╗██████╔╝  ██║░░░░░██║╚════██║
░░░╚═╝░░░░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░  ╚═╝░░░░░╚═╝░░░░░╚═╝
\e[0m"

echo -e "
=======================================================================================================
\e[36m  Hostnam       \e[0m      :\e[32m $HOSTNAME \e[0m
\e[36m  Distrib       \e[0m      :\e[32m `lsb_release -ds` \e[0m
\e[36m  Release       \e[0m      :\e[32m `uname -mrso` \e[0m
\e[36m  TimeZone      \e[0m      :\e[32m$TIME_ZONE \e[0m
\e[36m  Date          \e[0m      :\e[32m `date +"%A, %d %B %Y, %R"` \e[0m
\e[36m  Users         \e[0m      :\e[32m currently $(users | wc -w) user(s) logged on \e[0m
\e[36m  Current User  \e[0m      :\e[32m $USER \e[0m
\e[36m  System Uptime \e[0m      :\e[32m $upDays days $upHours hours $upMins minutes $upSecs seconds \e[0m"
if [ $MEMORY_PERCENTAGE -lt 90 ]
  then
        echo -e " \e[36m Memory Used\e[0m         :\e[32m $MEMORY1 MB / $MEMORY2 MB ($MEMORY_PERCENTAGE%)\e[0m"
  else
        echo -e " \e[31m Memory Used\e[0m         :\e[31m $MEMORY1 MB / $MEMORY2 MB ($MEMORY_PERCENTAGE%)\e[0m"

fi
if [ $CPU_PERCENTAGE -gt 90 ]
  then
        echo -e "\e[36m  Cpu Usage     \e[0m      :\e[32m $LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min) ($CPU_PERCENTAGE%)\e[0m"
  else
        echo -e "\e[36m  Cpu Usage     \e[0m      :\e[32m $LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min) ($CPU_PERCENTAGE%)\e[0m"
fi
echo -e "\e[36m  Disk Usage    \e[0m      :"
for i in $(lsblk | awk '{print $7}' | grep /)
    do
        filesystem=$(df -hP | grep -w "$i" | head -1 | awk '{print $5,"of",$2,"used"}')
        filesystem_percentage=$(df -hP | grep -w "$i" | head -1 | awk '{ print $5}' | tr -d '%')
        if [[ -n "$filesystem" ]]
            then
                if [ "$filesystem_percentage" -lt 90 ]
            then
                echo -e "\e[36m      Usage of ${i}\t\t\e[0m:\e[32m  $filesystem \e[0m"
            else
            echo -e "\e[31m      Usage of ${i}\t\t\e[0m:\e[31m  $filesystem \e[0m"
            fi
        fi
    done
echo "======================================================================================================="
