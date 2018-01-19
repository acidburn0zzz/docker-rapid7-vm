# Populate example site
USERAUTH=`echo -n $API_USER:$API_PASSWORD | openssl base64`

echo "Creating site(s)..."
RESPONSE=`curl -s -X POST \
            --header "Authorization: Basic $USERAUTH" \
            -k https://localhost:$CONSOLE_PORT/api/3/sites \
            -H 'Content-Type: application/json' \
            -d '{"description":"Site with sample scan configuration and discovery scan template assigned","name":"Example Site 1","scanTemplateId":"discovery","scan":{"assets":{"includedTargets":{"addresses":["host-1","host-2","host-3"]}}}}'`

# Create standard user account
