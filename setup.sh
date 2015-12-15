#!/bin/bash
. icinga2_env_vars
./create_hostgroups.sh
./create_hosts.sh
./create_services.sh
