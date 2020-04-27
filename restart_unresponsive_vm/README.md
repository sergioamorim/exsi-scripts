## restart_unresponsive_vm
This set of scripts check if a virtual machine responds to ICMP type 8 requests (using `/bin/ping`) and, if not, reboot the guest OS.

**It is necessary to edit the file restart_unresponsive_vm.sh**  to setup which VM will be checked, the quantity of pings failed to determine if the VM is unresponsive, the timeout of each ping, the path to the directory in which this set of scripts are located and a log file path.

The log file will be limited in size to 2MB + 2MB of archive.

### Quick tutorial
1. Place the files `restart_unresponsive_vm.sh` and `safe_run.sh` in the same directory on the VMware ESXi server.
2. Edit the file `restart_unresponsive_vm.sh` and fill out the constant variables on the lines below:
```
VMID=0 # vm id (find it with "vim-cmd vmsvc/getallvms | grep <vm name>")
TRIES=21 # quantity of pings failed to determine a host is unresponsive
TIMEOUT=10 # timeout of each ping in seconds
PATH="" # path to the directory in which both this script and safe_run.sh are located without trailing / (if it is in root, just keep it as an empty string)
LOG_PATH="/restart_unresponsive_vm.log" # path to log file
```

If you want to perform this host responsiveness verification periodically, you can add a *cronjob* to run the script `restart_unresponsive_vm.sh`.

3. Edit the file `/var/spool/cron/crontabs/root` to add a *cronjob* to run `restart_unresponsive_vm.sh`
    For example, add this line if `restart_unresponsive_vm.sh` is located in *root* to perform the responsiveness checks every hour on the minute 30:
      `30 * * * * /bin/sh /restart_unresponsive_vm.sh`
*Please note that lower values for the constant `TRIES` and/or `TIMEOUT` can lead to a loop or restarting the guest OS if you set the *cronjob* to run every minute.*
    **Hint**: you may need to use **w!** on `vi`  to force writing the file `/var/spool/cron/crontabs/root` because it is read only.
4.  After editing the *crontab*, restart the `crond` process:
```
kill -HUP $(cat /var/run/crond.pid)
/usr/lib/vmware/busybox/bin/busybox crond
```

If you need help to put something to work or want to suggest a new feature, report an error or have any feedback to give, please [open an issue here](https://github.com/sergioamorim/exsi-scripts/issues).
