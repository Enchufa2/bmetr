#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo """Usage: $0 <tend> <window> <file>
Cut an audio sample and extract the tempo.

  <tend>              beginning of the sample, in seconds, from the end.
  <window>            window size in seconds.
  <file>              file path.
  """
  exit 1
fi

source config.sh

FILE=$3
ANT=$1
WIN=$2

DUR=$(ffprobe -loglevel quiet -show_entries format=duration -of csv "$FILE" | cut -d"," -f2)
./sym_sample_start.sh $(echo "$DUR-$ANT" | bc -l) $WIN $FILE
