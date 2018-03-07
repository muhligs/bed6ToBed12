#!/bin/bash
inputfile="$1"

# merge overlapping bed6 entries with same names.
## this identifies the path to the accompagnying Rscript:
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
### The Rscript command to run
comvar=$(cat "$DIR"/mergeBed6.R | R --slave --args "$inputfile")

## the command to build the bed12 file
echo "$comvar" | awk '
BEGIN {
curname="start"
starts=0","
#curname=$4
}
{
# 1st record start
if(NR==1){
printf($1"\t"$2"\t")
lengths=$3-$2","
endpos=$3
startpos=$2
curname=$4
numex=1
d5=$5
d6=$6
}
if(NR!=1){
if($4!=curname){
# closing
printf(endpos"\t"curname"\t"d5"\t"d6"\t"startpos"\t"endpos"\t"0"\t"numex"\t"lengths"\t"starts"\n")
# opening
printf($1"\t"$2"\t")
curname=$4
startpos=$2
endpos=$3
d5=$5
d6=$6
numex=1
lengths=$3-$2","
starts=0","
} else {
lengths=lengths$3-$2","
starts=starts$2-startpos","
endpos=$3
numex++
}
}
}
END {
printf(endpos"\t"curname"\t"d5"\t"d6"\t"startpos"\t"endpos"\t"0"\t"numex"\t"lengths"\t"starts"\n")
}
' | sort -k1,1 -k2,2n -k4,4
