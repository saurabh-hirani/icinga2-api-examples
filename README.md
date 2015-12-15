### Introduction

* The aim of this repo is to give the user a one-stop shop for trying out the icinga2 API - right from running the docker image, creating/querying/deleting dummy data alongwith gotchas that you can mess around with dummy data before moving on to production servers.
* All the below examples are derived by referencing (icinga2 API)[http://docs.icinga.org/icinga2/snapshot/doc/module/icinga2/chapter/icinga2-api]
* Each example builds on the next i.e. before doing read operations, we create dummy data and so on.
* Setup/teardown scripts are also provided to create and delete the dummy data.
* Each update operation has a corresponding undo operation mentioned.
* The examples in this repo are a subset of the operations specified in (icinga2 API)[http://docs.icinga.org/icinga2/snapshot/doc/module/icinga2/chapter/icinga2-api]

### Host setup

* Use the community docker image

  ```bash
  $ docker run -d -ti --name icinga2-api -p 4080:80 -p 4665:5665 icinga/icinga2
  ```

  Update the **icinga2_env_vars** file in this repo

  ```bash
  $ cat > icinga2_env_vars

  export ICINGA2_HOST=192.168.1.x # your local machine IP here
  export ICINGA2_API_PORT=4665
  export ICINGA2_API_USER=root
  export ICINGA2_API_PASSWORD=icinga
  ```

  For the dashboard you get icinga web2 - use the credentials icingaadmin:icinga at http://192.168.1.103:4080/icingaweb2

* You can also use the (icinga2 vagrant box)[https://github.com/Icinga/icinga-vagrant]

### Dummy hostgroups, hosts, service setup

  * All of these examples work on dummy hosts, hostgroups and services created by running

  ```bash
  ./setup.sh
  ```

  * When you are done, tear down the data by doing:

  ```bash
  ./teardown.sh
  ```

### Examples

  * Update the API env vars - host, port, user, password in **icinga2_env_vars** and source it

  ```bash
  source icinga2_env_vars
  ```

  * Check if the api is working 

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/status" | python -m json.tool
  ```

  * Create a hostgroup - api_dummy_hostgroup

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -X PUT \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hostgroups/api_dummy_hostgroup" \
       -d '{ "attrs": { "display_name": "api_dummy_hostgroup" } }' | python -m json.tool
  ```

  or you can use the script present in this repo:

  ```bash
  ./create_hostgroups.sh
  ```

  * Create hosts and associate it with the above hostgroup

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' -X PUT \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1" \
       -d '{ "templates": [ "generic-host" ], "attrs": { "address": "8.8.8.8", "vars.os" : "Linux", "vars.hostgroups": "X,api_dummy_hostgroup,X", "groups": ["api_dummy_hostgroup"], "hostgroupsr": "X,api_dummy_hostgroup,X" } }' | python -m json.tool
  ```

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_2" \
       -H 'Accept: application/json' -X PUT \
       -d '{ "templates": [ "generic-host" ], "attrs": { "address": "8.8.4.4", "vars.os" : "Linux", "vars.hostgroups": "X,api_dummy_hostgroup,X", "groups": ["api_dummy_hostgroup"] } }' | python -m json.tool
  ```

  Don't worry about vars.hostgroups - it has an interesting use case as we will later.

  You can also use the script present in this repo:

  ```bash
  ./create_hosts.sh
  ```

  to create the above 2 hosts.

  * Create services and associate it with the above host

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' -X PUT \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/api_dummy_host_1!api_dummy_service_1" \
       -d '{ "templates": [ "generic-service" ], "attrs": { "display_name": "api_dummy_service_1", "check_command" : "dns", "vars.dns_lookup": "google-public-dns-a.google.com.", "vars.dns_expected_answer": "8.8.8.8", "host_name": "api_dummy_host_1" } }' | python -m json.tool
  ```

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' -X PUT \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/api_dummy_host_2!api_dummy_service_2" \
       -d '{ "templates": [ "generic-service" ], "attrs": { "display_name": "api_dummy_service_2", "check_command" : "dns", "vars.dns_lookup": "google-public-dns-b.google.com.", "vars.dns_expected_answer": "8.8.4.4", "host_name": "api_dummy_host_2" } }' | python -m json.tool
  ```

  or you can use the script present in this repo:

  ```bash
  ./create_services.sh
  ```

  * As the hostgroup, hosts and services created above form the base for further operations - you can create all of them through:

  ```bash
  ./setup.sh
  ```

  * Delete a service

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/api_dummy_host_1!api_dummy_service_1" 
  ```

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/api_dummy_host_2!api_dummy_service_2" 
  ```

  or you can use the script present in this repo:

  ```bash
  ./delete_services.sh
  ```

  * Delete a host

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1"
  ```

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_2"
  ```

  The above command will fail with the following error if there are other objects dependent on it (e.g. services dependent on host). In that case you either delete the object by using the flag **cascade** Or you delete the dependencies first. 


  ```bash
  {"results":[{"code":500,"errors":["Object cannot be deleted because other objects depend on it. Use cascading delete to delete it anyway."],"name":"api_dummy_host","status":"Object could not be deleted.","type":"Host"}]}
  ```

  Carry out a cascade delete like so:

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1?cascade=1" 
  ```

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_2?cascade=1"
  ```

  or you can use the script present in this repo:

  ```bash
  ./delete_hosts.sh
  ```

  In this case - delete the service, delete the host, delete the hostgroup in order. As of this writing if we do not use cascade, we have to reload icinga2 at each stage - delete the service, reload, delete the host, reload and so on.

  * Delete a hostgroup

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \ 
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hostgroups/api_dummy_hostgroup" 
  ```

  or you can use the script present in this repo:

  ```bash
  ./delete_hostgroups.sh
  ```

  The rest of the examples assume you have dummy host, hostgroup and services created.

  * Get all attributes for a specific host

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1"
  ```

  * Get host name, address of hosts belonging to a specific hostgroup

  You get to choose whether to send query string or request body (yes - a request body in GET - see the example)

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/?filter=match(%22*dummy*%22,host.groups)" | viewjson | less
  ```

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: GET' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/" \
       -d '{ "filter": "match(\"*dummy*\",host.groups)", "attrs": ["name", "address"] }' | python -m json.tool
  ```

  host.groups is an array and one would expect to give the following expression:

  ```bash
  '{ "filter": "match(\"api_dummy_hostgroup\",host.groups)", "attrs": ["name", "address"] }' | python -m json.tool
  ```

  to match the exact hostgroup. But that doesn't work. You have to do:

  ```bash
  '{ "filter": "match(\"*api_dummy_hostgroup*\",host.groups)", "attrs": ["name", "address"] }' | python -m json.tool
  ```

  to match api_dummy_hostgroup - which doesn't seem right. Because this would also match - crapi_dummy_hostgroup. We can do the exact matching by the following:

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: GET' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/" \
       -d '{ "filter": "match(\"*,api_dummy_hostgroup,*\",host.vars.hostgroups)", "attrs": ["name", "address"] }' | python -m json.tool
  ```

  * Get host name, address attributes for a specific host

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1?attrs=name&attrs=address"
  ```

  or

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: GET' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1" \
       -d '{ "attrs": ["name", "address"] }' | python -m json.tool
  ```

  For the examples from now on, we will use GET request with json request body.

  * Get display_name, check_command attribute for services applied for filtered hosts matching host.address == 8.8.8\*. Join the output with the hosts on which these checks run (services are applied to hosts)

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: GET' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/" \
       -d '{ "joins": ["host.name", "host.address"], "filter": "match(\"8.8.8*\",host.address)", "attrs": ["display_name", "check_command"] }' | python -m json.tool
  ```

  * Get all services in critical state

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD -s -k  "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services?attrs=display_name&joins=host.address&filter=service.state==2"
  ```

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: GET' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/" \
       -d '{ "joins": ["host.name", "host.address"], "filter": "service.state==2", "attrs": ["display_name", "check_command"] }' | python -m json.tool
  ```

  service.states - 0 = OK, 1 = WARNING, 2 = CRITICAL

  * Get all services in critical state and filter out the ones for which active checks are disabled

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: GET' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/" \
       -d '{ "joins": ["host.name", "host.address"], "filter": "service.state==2", "attrs": ["display_name", "check_command", "enable_active_checks"] }' \
       | jq '.results[] | select(.attrs.enable_active_checks)' | python -m json.tool
  ```

  Used jq because I could not figure out how to specify mulitiple 'AND' filters. As of this writing, adding multiple filters 'OR's them.

  You could very well feed your json to a program and filter out what you need.

  * Get all services for which active checks are disabled

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD \
       -H 'Accept: application/json' -H 'X-HTTP-Method-Override: GET' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/" \
       -d '{ "joins": ["host.name", "host.address"], "filter": "service.state==2", "attrs": ["display_name", "check_command", "enable_active_checks"] }' \
       | jq '.results[] | select(.attrs.enable_active_checks==false)' | python -m json.tool
  ```

  * Disable notifications for a host

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1" \
       -d '{ "attrs": { "enable_notifications": false } }' | python -m json.tool
  ```

  To undo:

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/hosts/api_dummy_host_1" \
       -d '{ "attrs": { "enable_notifications": true } }' | python -m json.tool
  ```

  * Disable notifications for all services of a host

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/" \
       -d '{ "filter": "host.name==\"api_dummy_host_1\"", "attrs": { "enable_notifications": false } }' | python -m json.tool
  ```

  To undo:

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/" \
       -d '{ "filter": "host.name==\"api_dummy_host_1\"", "attrs": { "enable_notifications": true } }' | python -m json.tool
  ```

  * Disable notifications for all hosts and services in a hostgroup

  Currently, the icinga2 API host and service level operations do not work at the level of hostgroup. So in order to achieve this, we have to find the hosts and services of a hostgroup and then disable notifications as above

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/" \
       -d '{ "filter": "match(\"*,api_dummy_hostgroup,*\",host.vars.hostgroups)", "attrs": { "enable_notifications": false } }' | python -m json.tool
  ```

  To undo:

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/objects/services/" \
       -d '{ "filter": "match(\"*,api_dummy_hostgroup,*\",host.vars.hostgroups)", "attrs": { "enable_notifications": true } }' | python -m json.tool
  ```

  * Schedule downtime for a host

  Know which type of downtime do you want to schedule: http://docs.icinga.org/icinga2/snapshot/doc/module/icinga2/chapter/advanced-topics#downtimes . For testing purposes, it is easier to do fixed downtime because flexible downtimes occur on a state change in the start-end interval.

  Schedule one as per instructions in schedule-downtime here: http://docs.icinga.org/icinga2/snapshot/doc/module/icinga2/chapter/icinga2-api#icinga2-api-actions . Play safe and provide the right duration in either case - fixed or flexible.

  ```bash
  $ date +%s
  1449057010

  $ date +%s --date="+30 seconds"
  1449057040

  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/actions/schedule-downtime" \
       -d '{ "type": "Host", "filter": "host.name==\"api_dummy_host_1\"", "start_time": 1449057685, "end_time": 1449057715, "author": "api_user", "comment": "api_comment", "fixed": true }' | python -m json.tool
  ```

  * Schedule downtime for all services of a host - change the timestamps accordingly

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/actions/schedule-downtime" \
       -d '{ "type": "Service", "filter": "host.name==\"api_dummy_host_1\"", "start_time": 1449064981, "end_time": 1449065129, "author": "api_user", "comment": "api_comment", "fixed": true }' | python -m json.tool
  ```

  * Schedule downtime for all hosts and services in a hostgroup - change the timestamps accordingly

  ```bash
  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/actions/schedule-downtime" \
       -d '{ "type": "Host", "filter": "match(\"*,api_dummy_hostgroup,*\",host.vars.hostgroups)", "start_time": 1449065680, "end_time": 1449065823, "author": "api_user", "comment": "api_comment", "duration": 120, "fixed": true }' | python -m json.tool

  curl -u $ICINGA2_API_USER:$ICINGA2_API_PASSWORD  \
       -H 'Accept: application/json' \
       -X POST \
       -k "https://$ICINGA2_HOST:$ICINGA2_API_PORT/v1/actions/schedule-downtime" \
       -d '{ "type": "Service", "filter": "match(\"*,api_dummy_hostgroup,*\",host.vars.hostgroups)", "start_time": 1449065680, "end_time": 1449065823, "author": "api_user", "comment": "api_comment", "duration": 120, "fixed": true }' | python -m json.tool
  ```
