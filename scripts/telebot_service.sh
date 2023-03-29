#!/bin/sh
### BEGIN INIT INFO
# Provides:          run_telebot
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Runs specific rake task to listen messages from telegram
### END INIT INFO
LOCATION=/root/docs_markup_bot
SCRIPT="/usr/local/rvm/rubies/ruby-3.1.2/bin/rake telebot:run RAILS_ENV=production"
RUNAS=root
PIDFILE=/var/run/run_telebot.pid
LOGFILE=/var/log/run_telebot.log
start() {
if [ -f /var/run/$PIDNAME ] && kill -0 $(cat /var/run/$PIDNAME); then
echo 'Service already running' >&2
return 1
fi
echo 'Starting service…' >&2
cd $LOCATION
local CMD="$SCRIPT &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"
echo 'Service started' >&2
}
stop() {
if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
echo 'Service not running' >&2
return 1
fi
echo 'Stopping service…' >&2
kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
kill -s 9 `ps -ax | grep telebot:run | head -n 1 | cut -f1 -d" "`
echo 'Service stopped' >&2
}
uninstall() {
echo -n "Are you really sure you want to uninstall this service? That cannot be undone. [yes|No] "
local SURE
read SURE
if [ "$SURE" = "yes" ]; then
    stop
    rm -f "$PIDFILE"
echo "Notice: log file is not be removed: '$LOGFILE'" >&2
    update-rc.d -f <NAME> remove
    rm -fv "$0"
fi
}
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
*)
echo "Usage: $0 {start|stop|restart|uninstall}"
esac
