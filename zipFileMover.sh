#!/bin/bash

# Author oleskiy.OS
# This script takes all .zip files from all subdirectories of source directory (from input)
# checks if inside .zip file is present at least one file which name contains defined pattern/s (here the
# file name pattern should have extension .txt or .docx and length 1 - 40 characters, but you can change it
# whatever you want). If pattern was found, script moves .zip file to the target directory (from input).
# If it is not a case, it leaves .zip file untouched. Source directory in any case will not be searched.
# All removed files also will be renamed as example below:
# pattern:
#   currentFilename_date_randomNumFrom0To100000.zip
# example:
#   someFilename_2020-09-23-180838637_32521.zip
#
# all subdirectories that contained at least one .zip file
# which had have a file with the pattern can be removed in the end of operation, you will be prompted about it,
# so be careful.

# Here you can define your patterns:


function checkInput() {
    echo "Checking input...";
    if [ "$1" = "" ] || [ "$2" = "" ]; then
      echo "Source, target dirs or pattern directories can't be empty...";
      echo "Check values.";
      exit 0;
    fi
    for arg in "$@"; do
      if [[ ${arg: -1} == "/"  ]]; then
        arg=${arg%?}
      fi
    done

}

function removeDirectories() {
  if [[ $toRemove =~ y|yes|Yes|YES  ]]; then
    rm -r "$1";
    echo "Directory removed: $1"
  fi
}

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

patterns=("{1,40}.txt$" "{1,40}.docx$");
IFS=$'|';
zipExtension=zip;
currentFilename="";

printf "=============================FileMover============================\n";
printf "Source directory... Only full path ex: /c/sourceFolder\n";
read -r sourceDir;
printf "Target directory... Only full path ex: /c/targetFolder\n";
read -r targetDir;
checkInput "$sourceDir" "$targetDir";
printf "Would you like to remove all directories where pattern was
found after files will be moved to the target directory? (y/n)\n";
read -r toRemove;

for zipArc in "${sourceDir}"/*/*."${zipExtension}";
  do
    if [ -f "${zipArc}" ]; then
      currentFilename=$(basename "${zipArc}" | cut -d "." -f1);
      if unzip -Z "${zipArc}" | grep -q -E "${patterns[*]}"; then
        echo "Current file: ${zipArc}"
        mv "${zipArc}" "${targetDir}/${currentFilename}_$(date '+%Y-%m-%d-%H%M%S%3N')_$(shuf -i 0-100000 -n 1).zip";
        removeDirectories "${zipArc%/*}";
      else
          echo "Zip Archive ${zipArc} does not have required pattern."
      fi
    fi
  done

echo "==============================Done.Exiting...====================="
exit 0