#!/bin/bash

INTERVAL=5
FG="%{F#FF579BC5}"
DIM="%{F#FF28485D}"
RED="%{F#FFff0000}"
BLUE=$FG
GREEN="%{F#FFa1b56c}"

DOT="•"

Clock() {
  DATE=$(date "+%F %R")
  echo "$DATE"
}

Battery() {
  BATPERC=$(acpi -b | awk '{print $4}' | sed 's/%\|,//g')
  if [[ $BATPERC -le 15 ]]; then
    echo "${RED}$BATPERC%"
  else
    echo "${DIM}$BATPERC%"
  fi
}

Mem() {
  MEM="$(grep MemAvailable /proc/meminfo | awk '{print $2}' | awk '{$1/=1024;printf "%.2fMB\n",$1}')"
  echo "${DIM}${MEM}"
}

Load() {
  LOAD="$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')"
  echo "${LOAD}"
}

# App - current focused window name
App() {
  if ! xdotool getwindowpid $(xdotool getwindowfocus) > /dev/null 2>&1
  then
    echo "" # window not found, just blank it
  else
    APP="$(cat /proc/$(xdotool getwindowpid $(xdotool getwindowfocus))/comm)"
    echo "${APP}"
  fi
}

Ssh() {
  SSH_CONNS=$(ps -ef | grep "ssh " | grep -v grep -c)
  if [[ $SSH_CONNS -ge 1 ]]; then
    echo "${GREEN}${DOT}"
  fi
}

Notification() {
  NOTIFY=$(test -f ~/.notify && cat ~/.notify)
  if [[ "$NOTIFY" == "E" ]]; then
    echo "${RED}${DOT}"
  elif [[ "$NOTIFY" != "" ]]; then
    echo "${BLUE}${DOT}"
  fi
}

while true; do
  # content
  LEFT="  $(Notification) $(Ssh)"
  CENTER="" #"$(App)"
  RIGHT="${FG}$(Mem) ${FG}$(Battery)${FG} | $(Clock)  "

  # output
  echo "${FG}%{l}${LEFT}%{c}${CENTER}%{r}${RIGHT}%{F-}"
  sleep $INTERVAL
done
