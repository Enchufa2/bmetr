#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo """Usage: $0 <ratio_tstart> <ratio_window> <file>
Cut an audio sample and extract the tempo.

  <ratio_tstart>      beginning of the sample as a ratio of the total duration.
  <ratio_window>      window size as a ratio of the total duration.
  <file>              file path.
  """
  exit 1
fi

source config.sh

FILE=$3
BRAT=$1
WRAT=$2

DUR=$(ffprobe -loglevel quiet -show_entries format=duration -of csv "$FILE" | cut -d"," -f2)
./sym_sample_start.sh $(echo "$DUR*$BRAT" | bc -l) $(echo "$DUR/$WRAT" | bc -l) $FILE
