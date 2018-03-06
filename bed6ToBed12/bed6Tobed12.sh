#!/bin/bash
#if [ "$1" != "-s" ]; then
#a=$(cut -f4,4 "$1" | sort | uniq | wc -l)
#b=$(cut -f4,4 "$1" | uniq | wc -l)
#if [ $a -ne $b ]; then
#echo "The bed6 file needs to be arranged by the name field. (cut -f4,4 file | uniq | wc -l should equal cut -f4,4 file | sort | uniq | wc -l)\n
#use parameter -s to let this program sort (cat input | sort -k1,1 -k4,4 -k2,2n)" >&2
#exit
#fi
inputfile="$1"
#comvar="cat $inputfile"
#fi


#if [ "$1" = "-s" ]; then
#inputfile="$2"
#fi
# merge overlapping bed6 entries with same names.
# echo "The script you are running has basename `basename $0`, dirname `dirname $0`"
comvar=$(cat `dirname $0`/bed6to12/mergeBed6.R | R --slave --args "$inputfile")
#comvar=$(cat `dirname $0`/bed6to12/mergeBed6.R | R --slave --args `$inputfile`"
#echo "$comvar" 
#cat "$comvar" 
#cat $(dirname $0)/bed6to12/mergeBed6.R | R --slave --args '$inputfile'
#exit 1


#comvar="cat $2 | sort -k1,1 -k4,4 -k2,2n"
#echo "$comvar" 
#cat "$inputfile" | sort -k1,1 -k4,4 -k2,2n |
#fi


#cat "$inputfile" | sort -k1,1 -k4,4 -k2,2n |
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
