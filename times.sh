#!/bin/bash
#
#  run:
#  nohup bash times.sh &

[ "$MON_URLS" ]  || { echo "ERROR: 'MON_URLS' value is missing"; exit; }
[ "$MON_NAMES" ] || { echo "ERROR: 'MON_NAMES' value is missing"; exit; }
[ "$DEST" ]      || { echo "ERROR: 'DEST' value is missing"; exit; }
[ "$SLEEP" ]     || { echo "ERROR: 'SLEEP' value is missing"; exit; }
[ "$FLAG" ]      || { echo "ERROR: 'FLAG' value is missing"; exit; }

# URLS count is a space count+1
spaces=" ${MON_URLS//[^ ]}"
[ "$DEBUG" ] && echo "Spaces: ($spaces)"

# replace spaces with -o /dev/null
redirs=${spaces// / -o \/dev\/null/}
[ "$DEBUG" ] && echo "Redirs: ($redirs)"

touch $FLAG

while [ -f $FLAG ] ; do
  d=$(date +"%F")
  dest=${DEST/\%F/$d}
  [ -f $dest ] || echo "Stamp,"$MON_NAMES > $dest
  f=$(date +"%F %H:%M:%S")
  [ "$DEBUG" ] && echo "$redirs $MON_URLS"
  ta=$(curl -w ' %{time_total}' -s $redirs $MON_URLS)
  tb=${ta//,/.}
  t=${tb// /,}
  echo "$f$t" >> $dest
  [ "$DEBUG" ] && echo "$f$t"
  sleep $SLEEP
done
echo "Done"
