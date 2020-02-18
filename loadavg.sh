#!/bin/bash
# 
#
#  run:
#  nohup bash loadavg.sh &
DATA_PATH=./data
DEST=avg
SLEEP=5
FLAG=loadavg.on

[ "$DATA_PATH" ] || { echo "ERROR: 'DATA_PATH' value is missing"; exit; }
[ "$DEST" ]      || { echo "ERROR: 'DEST' value is missing"; exit; }
[ "$SLEEP" ]     || { echo "ERROR: 'SLEEP' value is missing"; exit; }
[ "$FLAG" ]      || { echo "ERROR: 'FLAG' value is missing"; exit; }

DEBUG=1
# on linux
TOP=-n1
PS=-Af
# on freebsd
#TOP=""
#PS=-aux

mk_avg_bsd() {
  local src=$1
  local dst_prefix=$2
  local d=$3
  [[ "$d" ]] || d=$(date +"%F")
  local dst=${dst_prefix}.$d.log
  [ -f $dst ] || echo "Stamp,LoadAvg" > $dst

  grep "load averages" $src > $src.tmp
  while read f1 f2 f3 f4 f5 avg1 avg2 avg3 f9 f10 tm
  do
    avg1b=${avg1/,/}
    [[ "$DEBUG" ]] && echo "$d $tm,$avg1b"
    printf "$d $tm,$avg1b\n" >> $dst
  done < $src.tmp
  rm $src.tmp
}

mk_avg_linux() {
  local src=$1
  local dst_prefix=$2
  local d=$3
  [[ "$d" ]] || d=$(date +"%F")
  local dst=${dst_prefix}.$d.log
  [ -f $dst ] || echo "Stamp,LoadAvg" > $dst

  grep "load average:" $src > $src.tmp
  while read f1 f2 tm f3 f4 f5 f6 f7 f8 f9 f10 avg1 avg2 avg3
  do
    avg1a=${avg1/,/.}
    avg1b=${avg1a/,/}
    [[ "$DEBUG" ]] && echo "$d $tm,$avg1b"
    printf "$d $tm,$avg1b\n" >> $dst
  done < $src.tmp
  rm $src.tmp
}

touch $FLAG

while [ -f $FLAG ] ; do
  d=$(date +"%F")
  dest=$DATA_PATH/$d
  [ -d $dest ] || mkdir -p $dest
  ts=$(date +"%F_%T")
  ps $PS > $dest/$DEST.$ts.ps.log
  top -b $TOP > $dest.tmp
  cat $dest.tmp >> $dest/$DEST.$ts.top.log
  mk_avg_linux $dest.tmp $DATA_PATH/$DEST $d
  rm $dest.tmp
  sleep $SLEEP
done
echo "Done"
