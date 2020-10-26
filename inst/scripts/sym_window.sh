#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo """Usage: $0 <ratio_window> <ratio_shift> <file>
Extract the tempo from an audio file using a sliding window.

  <ratio_window>      window size as a ratio of the total duration.
  <ratio_shift>       window shift size as a ratio of the total duration.
  <file>              file path.
  """
  exit 1
fi

source config.sh

FILE=$3
R_WIN=$1
R_HOP=$2

DUR=$(ffprobe -loglevel quiet -show_entries format=duration -of csv "$FILE" | cut -d"," -f2)
WIN=$(echo "$DUR/$R_WIN" | bc -l)
HOP=$(echo "$DUR/$R_HOP" | bc -l)

START=0
TEMPO=$(./tempo_sample.sh $START $DUR "$FILE")
echo "$TEMPO $START $DUR"
while [ $(echo "$START+$HOP <= $DUR" | bc -l) -eq 1 ]; do
  TEMPO=$(./tempo_sample.sh $START $WIN "$FILE")
  echo "$TEMPO $START $WIN"
  START=$(echo "$START+$HOP" | bc -l)
done
