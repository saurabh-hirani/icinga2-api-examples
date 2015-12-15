#!/bin/bash
. icinga2_env_vars
./delete_services.sh
./delete_hosts.sh
./delete_hostgroups.sh
