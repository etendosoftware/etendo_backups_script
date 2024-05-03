#!/bin/bash
# ---------------------------------------------------------------------------
# reinicio_performance.sh - 

# Copyright 2018
  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

# Usage: reinicio_performance.sh [-h|--help] [-t|--tomcat action] [-p|--postgres action] [-j|--jstack]

# Revision history:
# 2018-04-07 Created by bash_generator.sh ver. 3.3
# ---------------------------------------------------------------------------

PROGNAME=${0##*/}
VERSION="1.0"

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  clean_up
  exit 1
}

graceful_exit() {
  clean_up
  exit
}

signal_exit() { # Handle trapped signals
  case $1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}

usage() {
  echo -e "Usage: $PROGNAME [-h|--help] [-t|--tomcat action] [-p|--postgres action] [-j|--jstack] [-q|--query]"
}

help_message() {
  cat <<- _EOF_
  $PROGNAME ver. $VERSION
  

  $(usage)

  Options:
  -h, --help  Display this help message and exit.
  -t, --tomcat action  tomcat
    Where 'action' is the action.
  -p, --postgres action  postgres
    Where 'action' is the action.
  -j, --jstack  jstack
  -q, --query

  NOTE: You must be the superuser to run this script.

_EOF_
  return
}

# Trap signals
trap "signal_exit TERM" TERM HUP
trap "signal_exit INT"  INT

# Check for root UID
#if [[ $(id -u) != 0 ]]; then
#  error_exit "You must be the superuser to run this script."
#fi

get_jstak() {
  echo ">> Executing jstack"; jstack $( jps -l | grep 'org.apache.catalina.startup.Bootstrap' | cut -d' ' -f1) > /home/etendo/jstack-$(date +%Y-%m-%d_%H.%M.%S).txt ; echo ">> Done."
}

get_sqlscript() {
  echo ">> Executing sql script"; psql -U postgres -h localhost -w -f /usr/share/etendo/backup/scripts/query.sql -o /home/etendo/querys-$(date +%Y-%m-%d_%H.%M.%S).sql; echo ">> Done."
}

# Parse command-line
while [[ -n $1 ]]; do
  case $1 in
    -h | --help)
      help_message; graceful_exit ;;
    -t | --tomcat)
      shift; action="$1"; get_jstak; echo ">> Executing sudo /etc/init.d/tomcat $action"; sudo /etc/init.d/tomcat $action; echo ">> Done." ;;
    -p | --postgres)
      shift; action="$1"; get_sqlscript; echo ">> Executing sudo /etc/init.d/postgresql $action"; sudo /etc/init.d/postgresql $action; echo ">> Done." ;;
    -j | --jstack)
      shift; get_jstak ;;
    -q | --query)
      shift; get_sqlscript ;;
    -* | --*)
      usage
      error_exit "Unknown option $1" ;;
    *)
      echo "Argument $1 to process..." ;;
  esac
  shift
done

# Main logic

graceful_exit
