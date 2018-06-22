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

# Trap CTRL+C, CTRL+Z and quit 
# trap '' SIGINT SIGQUIT SIGTSTP

## Define variables

DX="docker exec -it"
DXE="docker exec -it -e"
PROG1="/usr/local/bin/nmap -p80, 443, 3306 localhost -oG - tee 'perl nikto -h' /opt/sqlmap/sqlmap.py localhost "
PROG2="brakeman -q </path/to/application> -o output.json -o output"
PROG3="perl nikto -h localhost -p 80,88,443"
PROG4="/opt/sqlmap/sqlmap.py $1"
PROG5="/opt/debcheck/dependency-checker.sh <path/to/file or directory>"


## Functions
function nmap { $PROG1 }
#function brakeman { true; }
function nikto2 { $PROG3 }
#function sqlmap { true; }
#function OWASPdc { true; }

case "$CMD" in
  "nmap" )
    exec nmap
    ;;

  "nikto2" )
    # we can modify files here, using ENV variables passed in 
    # "docker create" command. It can't be done during build process.
    exec nikto2
    ;;

   * )
    # Run custom command. Thanks to this line we can still use 
    # "docker run our_image /bin/bash" and it will work
    exec $CMD ${@:2}
    ;;
esac




