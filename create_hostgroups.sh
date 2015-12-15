#!/bin/bash -e 

. icinga2_env_vars

echo "creating hostgroups"

curl -s -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
     -H 'Accept: application/json' -X PUT \
     -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hostgroups/api_dummy_hostgroup" \
     -d '{ "attrs": { "display_name": "api_dummy_hostgroup" } }' | python -m json.tool

sleep 5
