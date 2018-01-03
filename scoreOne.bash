#!/usr/bin/env bash
set -e
set -x
##
#
# score just one set of eyd files
#
# USAGE:
# 
#
#end
##

function helpandexit { 
 sed -n 's/# //p;/#end/q;' $0 ; exit 1;
}

[ -z "$1" ] && helpandexit
EYD_INPUT=$(readlink -f "$1")
[ ! -r "$EYD_INPUT" ] && echo "cannot find '$EYD_INPUT' ($1)" && exit 1


## get to script directory (for later bash and R source)
scriptdir=$(cd $(dirname $0); pwd)
cd $scriptdir


NCANDA_DIR="$(pwd)"


# DEFINE OUTPUT FOR PARSING EYD FILE INTO TXT FILE
EYD_OUTPUT="$NCANDA_DIR/raw/$(basename "$EYD_INPUT" .eyd).txt"
 
#
# convert to txt
#
${NCANDA_DIR}/autoeyescore/dataFromAnyEyd.pl "${EYD_INPUT}" > "${EYD_OUTPUT}"
# remove if cannot understand it's format
if [ $(wc -l < "${EYD_OUTPUT}" ) -lt 10 ]; then
  echo "Removed ${EYD_OUTPUT}! ${EYD_INPUT} looks bad" 
  rm "${EYD_OUTPUT}"
  exit 1
fi


#
# score! and plot
#
Rscript --verbose <(echo "
 # load up all the source files
 source('${NCANDA_DIR}/autoeyescore/RingReward/RingReward.settings.R');
 source('${NCANDA_DIR}/autoeyescore/ScoreRun.R');
 source('${NCANDA_DIR}/autoeyescore/ScoreEveryone.R');
 
 # get the run files and score
 print('looking for ${EYD_OUTPUT}');
 splitfile <- getFiles('${EYD_OUTPUT}'); # R function defined in RingReward.settings.R
 perRunStats <- scoreEveryone(splitfile,F,reuse=F);
")





