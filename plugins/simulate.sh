#!/bin/bash

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-H=<num host>] [-A=<host status>] [-e=<service status>] [-s=<name service>]
This script simulate service status
 
    -H|--host            Num hosts 1..10
    -A|--hostalive       host status UP,DOWN
    -e|--status          service status CRITICAL,WARNING,OK
    -s|--service         name service PING,CXMYSQL,CXHTTP 
EOF
}

 
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
    -e=*|--status=*)
      STATUSSERVICE="${i#*=}"
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

if [[ -n "${ALIVE}" ]]; then
  sed -i -r "s/HOST\[${NUMHOST}\]=.*/HOST\[${NUMHOST}\]=${ALIVE}/" etat.sh 
  echo "HOST n°${NUMHOST} is ${ALIVE}"
fi


if [[ -n "${NAMESERVICE}" ]]; then
  sed -i -r "s/${NAMESERVICE}\[${NUMHOST}\]=.*/${NAMESERVICE}\[${NUMHOST}\]=${STATUSSERVICE}/" etat.sh 
  echo "HOST n°${NUMHOST} SERVICE ${NAMESERVICE} is ${STATUSSERVICE}"
fi   


