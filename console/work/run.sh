#!/bin/bash

install_dir="/opt/rapid7/nexpose/nsc"

# Start nexpose
$install_dir/nexposeconsole.rc start

sleep 30

# Tail until log shows Nexpose has started
tail -f $install_dir/logs/nsc.log | sed '/Security Console web interface ready/ q'

# Activate console if environment variable set and not already active
USERAUTH=`echo -n $API_USER:$API_PASSWORD | openssl base64`
LICENSE_STATUS=`curl -s --header "Authorization: Basic $USERAUTH" -XGET -k "https://localhost:$CONSOLE_PORT/api/3/administration/license" | grep -m1 -oP '"status"\s*:\s*"\K[^"]+'`
echo "Current license status: $LICENSE_STATUS"

if [[ -v ACTIVATION_KEY ]] || [[ -v ACTIVATION_LICENSE_FILE ]]; then
    if [[ -z $LICENSE_STATUS ]] || [ $LICENSE_STATUS == "Unlicensed" ]; then
      echo '##############################'
      echo '##### Activating console #####'
      echo '##############################'
      RESPONSE=`curl -s --header "Authorization: Basic $USERAUTH" -H "Content-Type: multipart/form-data" -k -XPOST "https://localhost:$CONSOLE_PORT/api/3/administration/license?key="${ACTIVATION_KEY} -F "license="${ACTIVATION_LICENSE_FILE}`

      LICENSE_STATUS=`curl -s --header "Authorization: Basic $USERAUTH" -XGET -k "https://localhost:$CONSOLE_PORT/api/3/administration/license" | grep -m1 -oP '"status"\s*:\s*"\K[^"]+'`
      echo "Updated license status: $LICENSE_STATUS"
    fi
fi

# Seed data
if [[ -n $SEED_CONSOLE ]] && [ $SEED_CONSOLE == true ]; then
    echo '##############################'
    echo '####### Seeding console ######'
    echo '##############################'
    /bin/bash /work/seed.sh
fi


# Tail Nexpose console log
tail -f $install_dir/logs/nsc.log
