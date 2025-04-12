#!/run/current-system/sw/bin/bash
logLocation="$LOGS_DIRECTORY/$(/run/current-system/sw/bin/date +"%Y-%m-%d_%H:%m:%S").log"
ln -sf "$logLocation" "$LOGS_DIRECTORY/current.log"
echo "$0 starting service under $(pwd) with state directory $STATE_DIRECTORY, logging to $logLocation."
echo "Binary is: $1" >> $logLocation
echo "----------------------" >> $logLocation
$1 >> $logLocation 2>&1
