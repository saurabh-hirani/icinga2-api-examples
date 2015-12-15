#!/bin/bash -e

. icinga2_env_vars

echo "creating services"

curl -s -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
     -H 'Accept: application/json' -X PUT \
     -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/api_dummy_host_1!api_dummy_service_1" \
     -d '{ "templates": [ "generic-service" ], "attrs": { "display_name": "api_dummy_service_1", "check_command" : "dns", "vars.dns_lookup": "google-public-dns-a.google.com.", "vars.dns_expected_answer": "8.8.8.8", "host_name": "api_dummy_host_1" } }' | python -m json.tool

curl -s -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
     -H 'Accept: application/json' -X PUT \
     -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/api_dummy_host_2!api_dummy_service_2" \
     -d '{ "templates": [ "generic-service" ], "attrs": { "display_name": "api_dummy_service_2", "check_command" : "dns", "vars.dns_lookup": "google-public-dns-b.google.com.", "vars.dns_expected_answer": "8.8.4.4", "host_name": "api_dummy_host_2" } }' | python -m json.tool

sleep 5
