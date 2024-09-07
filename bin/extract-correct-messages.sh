#!/bin/bash

for I in *-critique.md
do
  cut-tag-content.sh correct-message "$I" \
  | perl -p -e 's/^ +//; s[</?original>|</?translation>][]g; s/ +$//;' \
  | uniq \
  > "$I.fix"
done
