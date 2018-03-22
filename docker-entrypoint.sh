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


# Trap CTRL+C, CTRL+Z and quit 
# trap '' SIGINT SIGQUIT SIGTSTP

## Define variables
ZAP_PATH="/usr/local/bin/zap/"
ZAP_PORT="8090"
ZAP_API_KEY="api_key"
DX="docker exec -it"
DXE="docker exec -it -e"
PROG1="exec lynis audit system remote $1 >> lynis.txt"
PROG2="/usr/local/bin/nmap <h_ip>"
PROG3="brakeman -q </path/to/application> -o output.json -o output"
PROG4="perl nikto -h <h_ip> -p 80,88,443"
PROG5="export http_proxy=http://localhost:8282; \
./bin/arachni <http://target-url> --scope-page-limit=0 --checks=*,-common_*,-backup*,-backdoors, \
-directory_listing --plugin=proxy --audit-jsons --audit-xmls; \
http_proxy=http://localhost:8282 curl http://arachni.proxy/shutdown; \
./bin/arachni <http://target-url> --scope-page-limit=0 --checks=*,-common_*,-backup*,-backdoors,-directory_listing \
 --plugin=vector_feed:yaml_file=vectors.yml"
PROG6="/opt/sqlmap/sqlmap.py"
PROG7="/opt/debcheck/dependency-checker.sh <<path/to/file or directory>"
PROG8="export ZAP_PORT; export ZAP_PATH; export ZAP_API_KEY; zap-cli quick-scan -s xss,sqli --spider -r  <h_ip>"


## Functions
function lynis { $PROG1; }
function nmap { true; }
function brakeman { true; }
function nikto2 { true; }
function arachni { true; }
function sqlmap { true; }
function OWASPdc { true; }
function zaproxy { true; }


## Autograb command line options & run indicated scripts on docker start
## Grab input from term or script & stuff them somewhere to use later
#while [ $# -gt 0 ]; do    # Until you run out of parameters . . .
#  case "$1" in
#               P1) lynis
#		;;
#		P2) nmap
#		;;
#		P3) brakeman
#		;;
#		P4) nikto2
#		;;
#		P5) arachni
#		;;
#		P6) sqlmap
#		;;
#		P7) OWASPdc
#		;;
#		P8) zaproxy
#             shift
#             if [ ! -f $P# ]; then
#                echo "Error: Program does not exist!"
#               exit $E_CONFFILE     # Program not found error.
#              fi
#              ;;
#  esac
#  shift       # Check next set of input parameters.
#done


## Whiptail for grabbing user-entered commands during testing
whiptail --title "Choose Tests" --checklist --separate-output "Which scan programs do you want to run?" 16 60 9 \
               P1 "Lynis" on \
               P2 "Nmap" off \
               P3 "Brakeman" off \
               P4 "Nikto2" off \
               P5 "Arachni" off \
               P6 "Sqlmap" off \
               P7 "OWASP dependency-checker" off \
               P8 "ZAProxy"   off 2>progchoices

while read -r choice
do
	case $choice in
		P1) lynis
		;;
		P2) echo "Nmap"
		;;
		P3) echo "Brakeman"
		;;
		P4) echo "Nikto2"
		;;
		P5) echo "Arachni"
		;;
		P6) echo "Sqlmap"
		;;
		P7) echo "OWASP Dependency-checker"
		;;
		P8) echo "ZAProxy"
		;;
		*)
		;;
	esac
done < progchoices




