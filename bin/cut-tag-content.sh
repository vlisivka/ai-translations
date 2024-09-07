#!/bin/sh

tag_name="${1:?ERROR: Tag name to cut is required.}"
shift 1

for input_file in "$@"
do

   start_tag="<$tag_name>"
   end_tag="</$tag_name>"

   in_body="no"
   while IFS= read -r line; do
       if [[ "$line" =~ "$start_tag" ]]; then
           line="${line/*$start_tag/}"
           in_body="yes"
       fi

       if [[ "$in_body" == "yes" ]]; then

         if [[ "$line" =~ "$end_tag" ]]; then
           line="${line/$end_tag*/}"
           in_body="no"
         fi

         echo "$line"
       fi
   done < "$input_file"

done
