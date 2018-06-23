#!/bin/bash 

#######################################
# A menu driven shell script to choose which tests to run. Tested on Debian Stretch + dockter-tom.
# We want to either 
## A) Allow a user to pick which scanning programs to run during testing or
## B) Grab the commands fed to this script from the command line using $@ + shift
# Tom Porter
# v1.0
#######################################

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

# $0 is a script name, 
# $1 is IP address
# $2 $3, $4, $5 are our command line arguments
CMD=$1

function nmap { "exec /usr/local/bin/nmap -p80, 443, 3306 localhost >> /opt/results; sleep infinity"; }
function start { "exec /bin/bash"; }

#PROG1="/usr/local/bin/nmap -p80, 443, 3306 localhost -oG - tee 'perl nikto -h' '/opt/sqlmap/sqlmap.py localhost' " >> /opt/results
#PROG1="/usr/local/bin/nmap -p80, 443, 3306 localhost >> /opt/results; sleep infinity"