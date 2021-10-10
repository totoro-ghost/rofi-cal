#!/usr/bin/env bash

# Use: Just a simple calendar
# Dependencies: cal or ncal, sed, date, cut, rofi
# Description: shows current month calendar
# Working: basic textfu and rofi dmenu mode
# Author: totoro

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
THEME="$DIR/theme2"

# remove the top two line and the highlight from cal
# for cal
# MAIN=$(cal | sed 's|_||g' | awk 'NR>2 {print}')
# for ncal
MAIN=$(ncal -b -h | awk 'NR>1 {print}')

SUN=$(echo "$MAIN" | cut -c 1,2)
MON=$(echo "$MAIN" | cut -c 4,5)
TUE=$(echo "$MAIN" | cut -c 7,8)
WED=$(echo "$MAIN" | cut -c 10,11)
THR=$(echo "$MAIN" | cut -c 13,14)
FRI=$(echo "$MAIN" | cut -c 16,17)
SAT=$(echo "$MAIN" | cut -c 19,20)

VAL="$SUN\n$MON\n$TUE\n$WED\n$THR\n$FRI\n$SAT"

DATE=$(date +'%_d')
DAY_STR=$(date +'%A')
MONTH=$(date +'%_m')
MONTH_STR=$(date +'%b')
YEAR=$(date +'%Y')

PROMPT="<span size=\"large\">$DATE</span><sup>-$MONTH_STR  <i>$DAY_STR</i></sup>"

# make current date active
ACTIVE=$(echo -e "$VAL" | grep -m 1 -n "$DATE" | cut -d':' -f1)
((ACTIVE = ACTIVE - 1))

SELECT=$(echo -e "$VAL" | rofi -dmenu -no-custom \
    -mesg "$PROMPT" \
    -theme "$THEME" \
    -matching prefix \
    -select "$DATE" \
    -u "0,1,2,3,4,5,6,7,14,21,28,35,42" \
    -a "$ACTIVE" )