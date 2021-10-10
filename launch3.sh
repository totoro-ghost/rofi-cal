#!/usr/bin/env bash

# Use: Just a simple calendar
# Dependencies: ncal, sed, date, cut, rofi
# Description: shows current month calendar
# Working: basic textfu and rofi dmenu mode
#          you cannnot go previous or forward than 12 months
# Author: totoro

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
THEME="$DIR/theme3"

#some indicators for other things
NEXT_MONTH=""
PREV_MONTH=""

# check if it is correct month
if [ "$#" -ne 0 ]; then
    TEMP=$(date +'%Y-%-m')
    if [ "$1" = "$TEMP" ]; then shift; fi
fi

# 0 i.e current date and month
if [ "$#" -eq 0 ]; then
    # remove the top line and the highlight
    MAIN=$(ncal -b -h | awk 'NR>2 {print}')
    DATE=$(date +'%_d')
    DAY_STR=$(date +'%A')
    MONTH=$(date +'%-m') # - don't pad the field
    MONTH_STR=$(date +'%b')
    YEAR=$(date +'%Y')
    PROMPT="$DATE-$MONTH_STR $DAY_STR"
else
    MAIN=$(ncal -b -h -d "$1" | awk 'NR>2 {print}')
    TEMP=$(ncal -b -h -d "$1" | head -1 | awk '{$1=$1;print}')
    MONTH_STR=$(echo "$TEMP" | cut -d' ' -f1)
    YEAR=$(echo "$TEMP" | cut -d' ' -f2)
    MONTH=$(echo "$1" | cut -d'-' -f2)
    PROMPT="$MONTH_STR $YEAR"
    ACTIVE="" #middle row last cell active
fi

SUN=$(echo "$MAIN" | cut -c 1,2)
MON=$(echo "$MAIN" | cut -c 4,5)
TUE=$(echo "$MAIN" | cut -c 7,8)
WED=$(echo "$MAIN" | cut -c 10,11)
THR=$(echo "$MAIN" | cut -c 13,14)
FRI=$(echo "$MAIN" | cut -c 16,17)
SAT=$(echo "$MAIN" | cut -c 19,20)

VAL="$SUN\n$PREV_MONTH\n$MON\n \n$TUE\n \n$WED\n \n$THR\n \n$FRI\n \n$SAT\n$NEXT_MONTH"

if [ $# -eq 0 ]; then
    # make current date active
    ACTIVE=$(echo -e "$VAL" | grep -m 1 -n "$DATE" | cut -d':' -f1)
    ((ACTIVE = ACTIVE - 1))
fi

# for printing
# su mo tu we th fr sa,
# you have to fix this every time you change the size in theme
PROMPT2="<span foreground=\"#e06b74\"><b>Su  Mo  Tu  We  Th  Fr  Sa</b></span>"

SELECT=$(echo -e "$VAL" | rofi -dmenu -no-custom -mesg "$PROMPT2" \
    -theme "$THEME" \
    -matching prefix \
    -select "$DATE" \
    -u "0,1,2,3,4,5" \
    -a "$ACTIVE" \
    -p "    $PROMPT")

# check for keybinds, alt+1 for prev, alt+2 for next
TEMP="$?"
if [ $TEMP -eq 10 ]; then
    SELECT="$PREV_MONTH"
elif [ $TEMP -eq 11 ]; then
    SELECT="$NEXT_MONTH"
fi

case "$SELECT" in
"$NEXT_MONTH")
    ((MONTH = MONTH + 1))
    if [ "$MONTH" -gt 12 ]; then
        MONTH="1"
        ((YEAR = YEAR + 1))
    fi
    $DIR/launch3.sh "$YEAR-$MONTH"
    ;;
"$PREV_MONTH")
    ((MONTH = MONTH - 1))
    if [ "$MONTH" -lt 1 ]; then
        MONTH="12"
        ((YEAR = YEAR - 1))
    fi
    $DIR/launch3.sh "$YEAR-$MONTH"
    ;;
*)
    # return the selected date
    DATE="$(echo "$SELECT" | sed 's/\ //g')"
    if [ -z "$DATE" ]; then
        exit
    fi
    DATE=$(printf "%02d\n" "$DATE")   #add 0 padding to date like 01
    MONTH=$(printf "%02d\n" "$MONTH") #add 0 padding to month like 01
    echo "$YEAR-$MONTH-$DATE" #you can now do what you like with this 
    ;;
esac