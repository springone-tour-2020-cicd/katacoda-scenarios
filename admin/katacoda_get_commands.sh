#!/bin/bash

# Usage:
#     source admin/katacoda_get_commands.sh
#     source admin/katacoda_get_commands.sh true      # includes metadata
#
# Get commands from Katacoda files
# Optionally include metadata ("```" and "```{{...}}" lines)
# Output will be written to temp/katacoda_commands

include_metadata=${1:-false}

DIRS="1-intro-workflow
2-kustomize
3-tekton
4-argocd
5-manage-triggers
6-buildpacks"

OUTPUT_DIR=temp/katacoda_commands
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

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
      echo "[get_commands] $input_file:$linenumber --- command block START"
      isCommandBlock=true
      if [[ $include_metadata = "true" ]]; then
        echo "$line" >> $output_file
      fi
      continue;
    elif [[ "$line" =~ ^\`\`\`{.*  ]]; then
      echo "[get_commands] $input_file:$linenumber --- command block END"
      isCommandBlock=false
      if [[ $include_metadata = "true" ]]; then
        echo "$line" >> $output_file
      fi
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
