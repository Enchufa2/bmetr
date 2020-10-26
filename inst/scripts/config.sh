#!/bin/bash

# path to the audio files
SYM_DIR=""

# path to Marsyas' bin/tempo program
TEMPO_BIN=""

# number of cores for parallel processing with launcher.sh
CORES=2

################################################################################

if ! [[ -x "$(command -v ffprobe)" && -x "$(command -v ffmpeg)" ]]; then
  echo "Error: ffmpeg is required, but was not found." >&2
  exit 1
fi

if ! [ -x "$(command -v $TEMPO_BIN)" ]; then
  echo "Error: Marsyas not found. Please, set TEMPO_BIN in config.sh." >&2
  exit 1
fi

if ! [ -d "$SYM_DIR" ]; then
  echo "Error: SYM_DIR does not exist. Please set SYM_DIR in config.sh." >&2
  exit 1
fi
