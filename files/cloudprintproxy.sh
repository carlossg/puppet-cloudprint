#!/bin/sh
### BEGIN INIT INFO
# Provides:          cloudprintproxy
# Required-Start:    cups $network $syslog
# Required-Stop:     cups $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Google Cloud Print Proxy
# Description:       Starts a Google Cloud Print Proxy
### END INIT INFO
 
# Author: Jeff Rebeiro <jeff@rebeiro.net>
# Fixes by: Carlos Sanchez http://csanchez.org
# http://blog.rebeiro.net/2012/12/google-cloud-print-daemon-for-ubuntu.html
 
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Google Cloud Print Proxy"
NAME=cloudprintproxy
DAEMON=/opt/google/chrome/chrome
DAEMON_ARGS="--type=service --enable-cloud-print-proxy --no-service-autorun --noerrdialogs --user-data-dir=/etc/cloudprint/"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
 
# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0
 
# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
 
# Exit if the Cloud Print configuration is not present
if ! [ -r "/etc/cloudprint/Service State" ]
  then
  echo "state file does not exist or not readable"
  exit 10
fi
 
# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh
 
# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions
 
#
# Function that starts the daemon/service
#
do_start()
{
 # Return
 #   0 if daemon has been started
 #   1 if daemon was already running
 #   2 if daemon could not be started
 
 # Ensure CUPS is running
 lpstat &> /dev/null || return 2
 
 # Test if daemon is already running
 start-stop-daemon --start --quiet --pidfile $PIDFILE -m --exec $DAEMON --test > /dev/null \
  || return 1
 
 # Start daemon
 start-stop-daemon --start --quiet --pidfile $PIDFILE -m -b --exec $DAEMON -- \
  $DAEMON_ARGS \
  || return 2
}
 
#
# Function that stops the daemon/service
#
do_stop()
{
 # Return
 #   0 if daemon has been stopped
 #   1 if daemon was already stopped
 #   2 if daemon could not be stopped
 #   other if a failure occurred
 start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
 RETVAL="$?"
 [ "$RETVAL" = 2 ] && return 2
 # Wait for children to finish too if this is a daemon that forks
 # and if the daemon is only ever run from this initscript.
 # If the above conditions are not satisfied then add some other code
 # that waits for the process to drop all resources that could be
 # needed by services started subsequently.  A last resort is to
 # sleep for some time.
 start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
 [ "$?" = 2 ] && return 2
 # Many daemons don't delete their pidfiles when they exit.
 rm -f $PIDFILE
 return "$RETVAL"
}
 
case "$1" in
  start)
 [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
 do_start
 case "$?" in
  0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
  2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
 esac
 ;;
  stop)
 [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
 do_stop
 case "$?" in
  0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
  2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
 esac
 ;;
  status)
       status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  restart)
 log_daemon_msg "Restarting $DESC" "$NAME"
 do_stop
 case "$?" in
   0|1)
  do_start
  case "$?" in
   0) log_end_msg 0 ;;
   1) log_end_msg 1 ;; # Old process is still running
   *) log_end_msg 1 ;; # Failed to start
  esac
  ;;
   *)
    # Failed to stop
  log_end_msg 1
  ;;
 esac
 ;;
  *)
 echo "Usage: $SCRIPTNAME {start|stop|status|restart}" >&2
 exit 3
 ;;
esac
 
:
