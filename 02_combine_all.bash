#!/usr/bin/env bash

# combine all eye scoring
# remove the header, add filename as first column
cd raw
for f in *.trial.txt; do 
 sed "1d;2,\$s/^/$(basename $f .trial.txt)\t/" $f
done | tee raw/all_score.txt
