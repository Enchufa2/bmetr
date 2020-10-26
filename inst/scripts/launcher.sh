#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo """Usage: $0 <script_params> <#symphony> <#movement>
Main program to launch sym_window.sh or sym_sample*.sh in parallel
to process a tree of audio files.

  <script_params>     quoted script name with input parameters.
  <#symphony>         symphony number (can be "*", but must be quoted).
  <#movement>         movement number (can be "*", but must be quoted).

Examples:
  Call script.sh with no parameters for symphony 3 and movement 1:
  $0 \"script.sh\" 3 1

  Call script.sh with parameters 'a', 'b' for all movements of symphony 3:
  $0 \"script.sh a b\" 3 \"*\"

  Call script.sh with parameters 'a', 'b' for all symphonies and movements:
  $0 \"script.sh a b\" \"*\" \"*\"
  """
  exit 1
fi

source config.sh

SCRIPT=$1
SYM=$2
MOV=$3

# Put all the files into an array
shopt -s dotglob
unset FILES i
while IFS= read -r -d $'\0' FILE; do
  FILES[i++]="$FILE"
done < <(find "$SYM_DIR" -name *No.$SYM*$MOV.*.mp3 -print0)

task() {
  readarray -t OUT <<< "$($1 "${2}")"
  for j in ${!OUT[@]}; do
    echo "${OUT[j]} \"$(basename "$(dirname "${2}")")\" \"$(basename "${2}")\""
  done
}
pmsem() { ((_i=_i%$1)); ((_i++==0)) && wait -n && ((_i--)); }

# Process the array in parallel
for i in ${!FILES[@]}; do
  echo -ne "\rProcessing $((i+1))/${#FILES[@]}..." >&2
  pmsem $CORES; task $SCRIPT "${FILES[i]}" &
done
wait

echo "" >&2
