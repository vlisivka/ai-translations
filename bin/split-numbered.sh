#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 [input_file]"
  exit 1
fi

NL=$'\n'

#primer="Перекладай українською з цього місця у форматі .po:"$'\n'
primer="msgid \"--help\tPrint this help message.\"${NL}msgstr \"--help\tНадрукувати цю довідку.\"$NL"


# Set 8-bit locale to measure string length in bytes
LC_ALL=C

for input_file in "$@"
do

  # Text to print to output file
  chunk=""
  chunk_size=1500

  # Last paragraph, which may not go to output file
  buffer=""

  i=0 # Chunk number
  p=0 # Paragraph number
  printf -v chunk_number '%05d' "$i"

  while IFS= read -r line; do
    buffer="$buffer$line$NL"

    if (( ${#line} == 0 ))
    then
      if (( (${#chunk} + ${#buffer}) > chunk_size ))
      then
        {
          # Priming
          echo "$primer"

          # Print text without last paragraph, because it's larger than chunk size
          echo -n "$chunk"

        } > "chunk-$chunk_number-$input_file"

        p=1
        chunk="#$p$NL$buffer"
        buffer=""

        let i+=1
        printf -v chunk_number '%05d' "$i"
      else
        let p+=1
        chunk="#$p$NL$buffer$chunk"
        buffer=""
      fi
    fi
  done < "$input_file"

  if [[ -n "$chunk$buffer" ]]; then
      {
        # Priming
        echo "$primer"

        # Text to translate
        echo "$chunk$buffer"
      } > "chunk-$chunk_number-$input_file"
  fi

done
