#!/bin/sh

VMID=0 # vm id (find it with "vim-cmd vmsvc/getallvms | grep <vm name>")
TRIES=21 # quantity of pings failed to determine a host is unresponsive
TIMEOUT=10 # timeout of each ping in seconds
PATH="" # path to the directory in which both this script and safe_run.sh are located without trailing / (if it is in root, just keep it as an empty string)
LOG_PATH="/restart_unresponsive_vm.log" # path to log file


# check if there is already a script running
now=$(/bin/date +"%Y-%m-%d %H:%M:%S")
if /bin/ps -c | /bin/grep -E "sh */bin/sh $PATH/safe_run.sh" &>/dev/null; then
  /bin/echo "$now - $PATH/${0##*/}: $PATH/safe_run.sh already running" >> $LOG_PATH
else
  /bin/echo "$now - $PATH/${0##*/}: started $PATH/safe_run.sh -v $VMID -t $TIMEOUT -c $TRIES -l $LOG_PATH" >> $LOG_PATH
  /bin/sh $PATH/safe_run.sh -v $VMID -t $TIMEOUT -c $TRIES -l $LOG_PATH
fi
