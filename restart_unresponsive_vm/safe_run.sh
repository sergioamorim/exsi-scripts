#!/bin/sh

# show usage and exit
show_usage() {
  echo "Usage: $0 -v <vmid> -t <timeout per try> -c <quantity of tries> -l <log path>"
  exit 1
}

# get values from opts
while getopts "v:t:c:l:" opt
do
   case "$opt" in
      v ) vmid="$OPTARG" ;;
      t ) timeout="$OPTARG" ;;
      c ) count="$OPTARG" ;;
      l ) log_path="$OPTARG" ;;
      ? ) show_usage ;;
   esac
done

# show usage if some variable is not set
if [ -z "$vmid" ] || [ -z "$timeout" ] || [ -z "$count" ] || [ -z "$log_path" ]
then
  show_usage
fi

# limiting size to 2MB (+2MB of archive)
log_size=$(($(/bin/wc -c $log_path  | /bin/awk '{print $1}')))
if [ $log_size -ge $((2*1024*1024)) ]; then
  /bin/mv $log_path $log_path'.1'
fi

# check if host is answers ping
host=$(/bin/vim-cmd vmsvc/get.guest $vmid | /bin/grep -m 1 "ipAddress = " | /bin/sed 's/   ipAddress = "//' | /bin/sed 's/", //')
index=1
# if vmtools is not running (as when the vm is yet starting) the ipAddress will be shown as unset;
# this loop tries to get the vm ip in a similar way the next loop tries to get a sucessful icmp response (and similar time to run)
# if no ip is found the next loop will fail as well and the vm will be restarted
while [[ $host -eq "   ipAddress = <unset>, " && $index -lt $count ]]; do
  host=$(/bin/vim-cmd vmsvc/get.guest $vmid | /bin/grep -m 1 "ipAddress = " | /bin/sed 's/   ipAddress = "//' | /bin/sed 's/", //')
  /bin/sleep $timeout
done
/bin/ping -c 1 -W $timeout $host &>/dev/null
ping=$?
index=1
while [[ $ping -eq 1 && $index -lt $count ]]; do
  /bin/ping -c 1 -W $timeout $host &>/dev/null
  ping=$?
  index=$(($index+1))
done

# restart host if it does not answer ping
NOW=$(/bin/date +"%Y-%m-%d %H:%M:%S")
if [ $ping -eq 0 ]; then /bin/echo "$NOW - ${0##*/}: $host online" >> $log_path
else
  /bin/echo "$NOW - ${0##*/}: $host offline - restarting" >> $log_path
  # the reset command is used instead of reboot because reboot requires vmtools running (and responding) on the vm
  /bin/vim-cmd vmsvc/power.reset $vmid >> $log_path 2>&1
  /bin/sleep $(($timeout*$count))  # prevents reseting the vm when its starting after being reset
fi
