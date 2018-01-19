#!/bin/bash

install_dir="/opt/rapid7/nexpose/nse"
consoleFile="$install_dir/conf/consoles.xml"
consoles_xml="consoles.xml"

if [[ -v SECRET ]]; then
  sed -i "s/SUPERSECRETKEY/$SECRET/g" $consoles_xml
  sed -i "s/CONSOLE/$CONSOLE/g" $consoles_xml
  mv $consoles_xml $consoleFile
else
  string="<cert></cert>"
  $install_dir/nexposeengine.rc start
  while true
  do
    if [ ! -f $consoleFile ]; then
      sleep 10
    else
      console=`eval cat $consoleFile`
      if [[ $console == *"$string"* ]]; then
        sleep 10
      else
        sed -i "s/enabled\=\"0\"/enabled\=\"1\"/g" $consoleFile
        $install_dir/nexposeengine.rc stop
        break
      fi
    fi
  done
fi

# Start nexpose
$install_dir/nexposeengine.rc start

sleep 3

# Tail Nexpose console log
tail -f $install_dir/logs/nse.log
