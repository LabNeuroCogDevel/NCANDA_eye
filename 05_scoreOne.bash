#!/usr/bin/env bash
set -e
#set -x
##
#
# score just one set of eyd files
#
# USAGE:
# 
#  ./scoreOne.bash -n # run on newest
#  ./scoreOne.bash -i # run interactively (will prompt for paradigm, subject and  date)
#  ./scoreOne.bash -D /mnt/B/bea_res/Data/Tasks/BarsBehavioral/Basic/11198/20130711
#  ./scoreOne.bash -D ~/rcn/bea_res/Data/Tasks/BarsBehavioral/Basic/11198/20130711/
#  ./scoreOne.bash -p BarsBehavioral -s 11198 -d 20130711
# 
#  options:
#   -i [prompt for what to do]
#   -n [act on newest]
#   -N [only print the newest update, don't run]
#   -D DIR [path to visit dir you want to parse]
#  OR
#   -p PARADIGM
#   -s SUBJECT
#   -d DATE
# 
# expect to find eyd files in PARADIGM/SUBJECT/DATE/
#
#
#
#end
##

function helpandexit { 
 sed -n 's/# //p;/#end/q;' $0 ; exit 1;
}

[ -z "$1" ] && helpandexit

while [ -n "$1" ]; do
 opt=$1; shift;
 case "$opt" in
  -s) subject=$1;  shift;;
  -y) year=$1;     shift;;
  -r) run=$1; shift;;
  -n) AUTO=1;;
  -N) ONLYSHOWNEW=1;;
  -D) usedir=$1; AUTO=1; shift;;
  -i) interactive=1;;
   *) helpandexit;;
 esac
done


subject=`echo $subject | awk -F ' ' '{ printf("%03d\n", $1) }'`


## get to script directory (for later bash and R source)
scriptdir=$(cd $(dirname $0); pwd)
cd $scriptdir

NCANDA_DIR="/Users/ncanda/Documents/Research/NCANDA"

originalEyeDataDir="${NCANDA_DIR}/data_eye"
#originalEyeDataDir="/Volumes/ns1/DeptShare/ClarkProjects/NCANDA/Data/Eye-trac Data"
## where is the data?
#[ ! -r $originalEyeDataDir ] && originalEyeDataDir="/Volumes/ns1/DeptShare/ClarkProjects/NCANDA/Data/Eye-trac Data/"

# IDENTIFY EYD FILE FOR SUBJECT, YEAR, AND RUN
subjdir=${originalEyeDataDir}/A${subject}

[ ! -r $subjdir ] && echo "subject ${subject} does not seem to have an eye directory" && exit 1


EYD_INPUT=`ls "${subjdir}/A${subject}_y${year}_Eraw_run$run.eyd"`


# DEFINE OUTPUT FOR PARSING EYD FILE INTO TXT FILE
EYD_OUTPUT=${subjdir}/${subject}_y${year}_run$run.txt
 
#
# convert to txt
#
${NCANDA_DIR}/scripts/autoeyescore/dataFromAnyEyd.pl "${EYD_INPUT}" > "${EYD_OUTPUT}"
# remove if cannot understand it's format
[ $(wc -l ${EYD_OUTPUT} | cut -f4 -d ' ') -lt 10 ] && echo "Removed ${EYD_OUTPUT}! ${EYD_INPUT} looks bad" && rm ${EYD_OUTPUT}


#
# score! and plot
#
Rscript --vanilla  --verbose <(echo "
 # load up all the source files
 source('${NCANDA_DIR}/scripts/autoeyescore/RingReward/RingReward.settings.R');
 source('${NCANDA_DIR}/scripts/autoeyescore/ScoreRun.R');
 source('${NCANDA_DIR}/scripts/autoeyescore/ScoreEveryone.R');
 
 # get the run files and score
 print('looking for ${EYD_OUTPUT}');
 splitfile <- getFiles('${EYD_OUTPUT}'); # R function defined in RingReward.settings.R
 perRunStats <- scoreEveryone(splitfile,F,reuse=F);

 # plot
 plotCatagories <- c('subj','PSCor','PSCorErr','PSErr','ASCor','ASErrCor','ASErr','OSCor','OSErrCor','OSErr','Dropped','total')
 sums     <- aggregate(. ~ subj, perRunStats[,plotCatagories],sum)
 longsums <- melt(sums[,names(sums) != 'total'],id.vars='subj') 
 byrun    <- melt(perRunStats[,!grepl('lat|total|type',names(perRunStats))], id.vars=c('subj','date','run') )

 p.allbd<- ggplot(byrun) + geom_histogram(aes(x=variable,y=value,fill=variable),stat='identity') +
           facet_grid(.~run)+ggtitle('per run')+ theme(axis.text.x = element_text(angle = 90)) 
 p.subj <- ggplot( longsums ) + ggtitle('per subject breakdown of collected data') +
          geom_histogram(aes(x=subj,y=value,fill=variable),stat='identity')
 #p.drpd<- ggplot(perRunStats) + geom_histogram(aes(x=Dropped))


 # show each plot
 if (FALSE) { # SET TO TRUE TO SHOW PLOTS
	  x11()
	  cat('\npress anykey to plot');
	  readLines(file('stdin'),1)
	 for(p in list(p.allbd,p.subj)){
	  print(p)
	  cat('\npress anykey');
	  readLines(file('stdin'),1)
	 }
 }
")





