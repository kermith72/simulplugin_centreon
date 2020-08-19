#!/bin/bash

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-H=<num host>] [-A=yes] [-I=<Host IP>] [-s=<name service>]
This script simulates a Centreon plugin and returns a status based on the parameters
 
    -H|--host            Num hosts 1..10
    -A|--hostalive       yes plugin for host (bas_check_alive), no check service for host
    -I|--ip              Host IP
    -s|--service         name service PING,CXMYSQL,CXHTTP 
EOF
}

ALIVE="yes"
 
for i in "$@"
do
  case $i in
    -H=*|--host=*)
      NUMHOST="${i#*=}"
      shift # past argument=value
      ;;
    -A=*|--hostalive=*)
      ALIVE="${i#*=}"
      shift # past argument=value
      ;;
    -I=*|--ip=*)
      IPHOST="${i#*=}"
      shift # past argument=value
      ;;
    -s=*|--service=*)
      NAMESERVICE="${i#*=}"
      shift # past argument=value
      ;;
    -h|--help)
      show_help
      exit 3
      ;;
    *)
            # unknown option
    ;;
  esac
done

BASE_DIR=$(dirname $0)

. $BASE_DIR/etat.sh

if [[ "${ALIVE}" == "yes" ]]; then
   
   #
   #check host
   #

   if [[ "${HOST[${NUMHOST}]}" == "UP" ]]; then
      echo "OK - ${IPHOST} rta 0,138ms lost 0%|rta=0,138ms;3000,000;5000,000;0; rtmax=0,138ms;;;; rtmin=0,138ms;;;; pl=0%;80;100;0;100"
      exit 0
   fi

   if [[ "${HOST[${NUMHOST}]}" == "DOWN" ]]; then
      echo "CRITICAL - ${IPHOST}: Host unreachable @ 192.168.1.98. rta nan, lost 100%|pl=100%;80;100;0;100"
      exit 2
   fi
else

   #
   #check service
   #

   if [[ "${NAMESERVICE}" == "PING" ]]; then

      #
      # PING
      #
  
      if [[ "${PING[${NUMHOST}]}" == "OK" ]]; then
         echo "OK - ${IPHOST} rta 1,559ms lost 0%|rta=1,559ms;200,000;400,000;0; rtmax=2,208ms;;;; rtmin=1,217ms;;;; pl=0%;20;50;0;100"
         exit 0
      fi

      if [[ "${PING[${NUMHOST}]}" == "CRITICAL" ]]; then
         echo "CRITICAL - ${IPHOST}: rta nan, lost 100%|pl=100%;20;50;0;100"
         exit 2
      fi
      if [[ "${PING[${NUMHOST}]}" == "WARNING" ]]; then
         echo "WARNING - ${IPHOST} rta 1,559ms lost 0%|rta=240,559ms;200,000;400,000;0; rtmax=280,208ms;;;; rtmin=140,217ms;;;; pl=0%;20;50;0;100"
         exit 1
      fi
   fi 

   if [[ "${NAMESERVICE}" == "CXMYSQL" ]]; then
 
      #
      #Connection-Time
      #

      if [[ "${CXMYSQL[${NUMHOST}]}" == "OK" ]]; then
         echo "OK: Connection established in 0.014s. | 'connection_time'=14ms;0:1000;0:5000;0;"
         exit 0
      fi
      
      if [[ "${CXMYSQL[${NUMHOST}]}" == "CRITICAL" ]]; then
         echo "CRITICAL: Cannot connect: Can't connect to MySQL server on ${IPHOST} (111 "Connexion refusée") |"
         exit 2
      fi
      if [[ "${CXMYSQL[${NUMHOST}]}" == "WARNING" ]]; then
         echo "WARNING: Connection established in 2.114s. | 'connection_time'=2114ms;0:1000;0:5000;0;"
         exit 1
      fi
   fi

   if [[ "${NAMESERVICE}" == "CXHTTP" ]]; then
 
      #
      #HTTP-Response-Time	
      #

      if [[ "${CXHTTP[${NUMHOST}]}" == "OK" ]]; then
         echo "OK: Response time 0.065s | 'time'=0.065s;;;0; 'size'=3162B;;;0;"
         exit 0
      fi
      
      if [[ "${CXHTTP[${NUMHOST}]}" == "CRITICAL" ]]; then
         echo "CRITICAL: 500 Can't connect to ${IPHOST}:80 (Connexion refusée) | 'time'=0.010s;;;0; 'size'=162B;;;0;"
         exit 2
      fi
      if [[ "${CXHTTP[${NUMHOST}]}" == "WARNING" ]]; then
         echo "WARNING: Response time 0.600s | 'time'=0.600s;0:0.5;;0; 'size'=3162B;;;0;"
         exit 1
      fi
   fi
fi

