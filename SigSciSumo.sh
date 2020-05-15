#!/bin/bash

#set path for the log file for the Python script to redirect request json to sdout
#set the location of SigSci.py
#set the request interval for the requests
#set the Sumo Logic Collector URL
SIGSCI_EVENTLOG="/tmp/sigsci_events.log"
SIGSCI_PYTHONSCRIPT="/app/SigSci.py"
SIGSCI_REQUESTINTERVAL="-5m"
SUMOLOGIC_URL=""

/usr/local/bin/python $SIGSCI_PYTHONSCRIPT --from=$SIGSCI_REQUESTINTERVAL > $SIGSCI_EVENTLOG

#checks that the request log file exists
if [ -f $SIGSCI_EVENTLOG ]
then
  #checks that the request log file isn't empty. that will happen if no requests were returned for the interval
  if [ -s $SIGSCI_EVENTLOG ]
  then
    #each line other than the first starts with ,{
    #sed will replace '{ with { to allow Sumo Logic to split out each request
    sed -i -e 's/,{/{/g' $SIGSCI_EVENTLOG
    #posts the request log file contents to the Sumo Logic Collector URL
    curl -v -X POST -T $SIGSCI_EVENTLOG $SUMOLOGIC_URL
  else
    echo "$SIGSCI_EVENTLOG is empty"
  fi
else
  echo "$SIGSCI_EVENTLOG does not exist"
fi
