#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo """Usage: $0 <tstart> <window> <file>
Cut an audio sample and extract the tempo.

  <tstart>            beginning of the sample, in seconds, from the start.
  <window>            window size in seconds.
  <file>              file path.
  """
  exit 1
fi

source config.sh

FILE=$3
START=$1
WIN=$2

DUR=$(ffprobe -loglevel quiet -show_entries format=duration -of csv "$FILE" | cut -d"," -f2)
TEMPO=$(./tempo_sample.sh $START $WIN "$FILE")
PULSES=$(echo "$DUR*$TEMPO/60" | bc -l)
echo "$DUR $START $WIN  $PULSES $TEMPO"
