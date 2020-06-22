#!/bin/bash

# Get commands from Katacoda files

DIRS="1-intro-workflow
2-kustomize
3-tekton
4-argocd
5-manage-triggers
6-buildpacks"

OUTPUT_DIR=demos
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

function get_commands() {
  input_file=${1}
  output_file=${2}
  echo "[get_commands] Input file $input_file -----> Output file $output_file"

  isCommandBlock=false
  linenumber=0
  while read line; do
    ((linenumber=linenumber+1))
    # echo "[get_commands] $input_file:$linenumber"
    # Update isCommandBlock if necessary
    if [[ "$line" =~ ^\`\`\`$ ]]; then
      isCommandBlock=true
      echo "[get_commands] $input_file:$linenumber --- command block START"
      continue;
    elif [[ "$line" =~ ^\`\`\`{.*  ]]; then
      isCommandBlock=false
      echo "[get_commands] $input_file:$linenumber --- command block END"
      continue;
    fi

    if [[ $isCommandBlock = "true" ]]; then
      echo "$line" >> $output_file
    fi

  done <$input_file

}

# loop through directories
for dir in $DIRS
do
  # loop through files in a directory
  for file in $dir/step[1-9].md
  do
    script=$OUTPUT_DIR/$dir.txt
    #echo -e "Input file $file -----> Output file $script"
    touch $script
    get_commands $file $script
  done    # loop through files in a directory
done    # loop through directories
