#!/bin/bash -e

. icinga2_env_vars

echo "creating hosts"

curl -s -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
     -H 'Accept: application/json' -X PUT \
     -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1" \
     -d '{ "templates": [ "generic-host" ], "attrs": { "address": "8.8.8.8", "vars.os" : "Linux", "vars.hostgroups": "X,api_dummy_hostgroup,X", "groups": ["api_dummy_hostgroup"] } }' | python -m json.tool

curl -s -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
     -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_2" \
     -H 'Accept: application/json' -X PUT \
     -d '{ "templates": [ "generic-host" ], "attrs": { "address": "8.8.4.4", "vars.os" : "Linux", "vars.hostgroups": "X,api_dummy_hostgroup,X", "groups": ["api_dummy_hostgroup"] } }' | python -m json.tool

sleep 5
