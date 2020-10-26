#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo """Usage: $0 <start> <duration> <file>
Extract the tempo from a music sample defined by a start time and duration.
Requires ffmpeg to cut the audio file and Marsyas to process the sample.

  <start>             start time in seconds.
  <duration>          duration of the fragment in seconds.
  <file>              file path.
  """
  exit 1
fi

source config.sh

clean() { rm -rf $TMP; }
trap clean SIGINT

FILE=$3
START=$1
DUR=$2

NAME=$(basename "$FILE")
EXT="${NAME##*.}"
TMP=$(mktemp --suffix=.$EXT)

# cut the sample
ffmpeg -loglevel quiet -y -ss $START -t $DUR -i "$FILE" -acodec copy $TMP
# extract the tempo and remove the sample
$TEMPO_BIN $TMP
clean
