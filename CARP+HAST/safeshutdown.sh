#!/bin/sh

syslog_facility="user.notice"
syslog_tag="carp-hast"
maxwait=60
delay=3

logger="/usr/bin/logger -p $syslog_facility -t $syslog_tag"

case "${1}" in
start)
        ;;
stop)
        if /usr/sbin/service postgresql onestatus | /usr/bin/grep -q "server is running" || \
                /usr/sbin/service postgresql onestatus | /usr/bin/grep -q "running as" ; then
                /usr/sbin/service postgresql onestop \
                || $logger "Unable to stop service: postgresql."

                                if /usr/sbin/service postgresql onestatus | /usr/bin/grep -q "is not running" || \
                                /usr/sbin/service postgresql onestatus | /usr/bin/grep -q "no server running" ; then
                                        echo "Stop postgresql for shutdown success."
                                        $logger "Stop postgresql for shutdown success."
                                else
                                        echo "Stop postgresql for shutdown failed"
                                        $logger "Stop postgresql for shutdown failed"
                                fi
        fi

                hastdevs=$(/sbin/hastctl dump | /usr/bin/awk '/^[[:space:]]*resource:[[:space:]]/ {print $2}')
                for mdev in $(/sbin/mount -p | /usr/bin/awk '/^\/dev\/hast\// {print $1}'); do
                        for hdev in $hastdevs; do
                                if [ "$mdev" = "/dev/hast/$hdev" ]; then
                                        /sbin/umount -f $mdev \
                                        || $logger "Unable to unmount: ${mdev}."
                                        $logger "Unmount ${mdev} for shutdown/reboot success."
                                fi
                        done
                done
        ;;
*)
        echo "Usage: $0 {start|stop}"
        ;;
esac

exit 0
